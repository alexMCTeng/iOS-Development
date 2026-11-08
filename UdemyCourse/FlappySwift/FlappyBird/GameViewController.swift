//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        
        let path = Bundle.main.path(forResource: file, ofType: "sks")
        
        let sceneData: Data?
        do {
            sceneData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        let archiver = NSKeyedUnarchiver(forReadingWith: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController {
    private var foldJumpDetector = FoldJumpDetector()

    #if DEBUG && targetEnvironment(simulator)
    private var usesTestAngle = false
    private var lastDeviceAngle: CGFloat?
    private var foldTriggerCount = 0
    private let foldStatusLabel = UILabel()
    private let foldTestSlider = UISlider()
    private let foldTestControls = UIStackView()
    #endif

    override func loadView() {
        let skView = SKView(frame: .zero)
        skView.backgroundColor = .black
        view = skView
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }

        configureHingeInput()
        #if DEBUG && targetEnvironment(simulator)
        configureFoldTestPanel()
        #endif
    }

    private func configureHingeInput() {
        if #available(iOS 27.1, *) {
            let interaction = UIHingeInteraction { [weak self] _, update in
                guard let self = self else { return }
                #if DEBUG && targetEnvironment(simulator)
                self.lastDeviceAngle = update.hinge?.angle
                guard !self.usesTestAngle else { return }
                #endif
                guard self.view.window?.windowScene?.activationState == .foregroundActive else {
                    self.handleHingeAngle(nil)
                    return
                }
                self.handleHingeAngle(update.hinge?.angle)
            }
            view.addInteraction(interaction)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillDeactivate(_:)),
                                               name: UIScene.willDeactivateNotification, object: nil)
    }

    @objc private func sceneWillDeactivate(_ notification: Notification) {
        guard let scene = notification.object as? UIWindowScene,
              scene === view.window?.windowScene else { return }
        handleHingeAngle(nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handleHingeAngle(nil)
    }

    /// The single input path for real hinge updates and simulator test angles.
    func handleHingeAngle(_ angle: CGFloat?) {
        let didTrigger = foldJumpDetector.consume(angleInRadians: angle)
        if didTrigger {
            let gameScene = (view as? SKView)?.scene as? GameScene
            gameScene?.performPrimaryAction()
        }
        #if DEBUG && targetEnvironment(simulator)
        if didTrigger { foldTriggerCount += 1 }
        let source = usesTestAngle ? "Test" : "Device"
        let angleText = angle.map { String(format: "%.0f°", Double($0 * 180 / .pi)) } ?? "no hinge"
        let state = foldJumpDetector.isArmed ? "armed" : "open >120°"
        foldStatusLabel.text = "\(source): \(angleText) · \(state) · folds: \(foldTriggerCount)"
        #endif
    }

    #if DEBUG && targetEnvironment(simulator)
    private func configureFoldTestPanel() {
        foldStatusLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        foldStatusLabel.textColor = .white
        foldStatusLabel.numberOfLines = 0
        foldStatusLabel.accessibilityIdentifier = "foldStatus"

        let toggle = UIButton(type: .system)
        toggle.setTitle("Fold test: off — use device hinge", for: .normal)
        toggle.addTarget(self, action: #selector(toggleFoldTest(_:)), for: .touchUpInside)

        foldTestSlider.minimumValue = 0
        foldTestSlider.maximumValue = 180
        foldTestSlider.value = 130
        foldTestSlider.accessibilityLabel = "Simulated hinge angle in degrees"
        foldTestSlider.addTarget(self, action: #selector(testAngleChanged), for: .valueChanged)

        let presets = UIStackView()
        presets.axis = .horizontal
        presets.distribution = .fillEqually
        for degrees in [130, 80] {
            let button = UIButton(type: .system)
            button.tag = degrees
            button.setTitle("\(degrees)°", for: .normal)
            button.addTarget(self, action: #selector(useTestPreset(_:)), for: .touchUpInside)
            presets.addArrangedSubview(button)
        }
        foldTestControls.axis = .vertical
        foldTestControls.addArrangedSubview(foldTestSlider)
        foldTestControls.addArrangedSubview(presets)
        foldTestControls.isHidden = true

        let panel = UIStackView(arrangedSubviews: [foldStatusLabel, toggle, foldTestControls])
        panel.axis = .vertical
        panel.spacing = 4
        panel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        panel.layer.cornerRadius = 8
        panel.tintColor = .white
        panel.isLayoutMarginsRelativeArrangement = true
        panel.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            panel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            panel.widthAnchor.constraint(lessThanOrEqualToConstant: 330),
            panel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
        handleHingeAngle(nil)
    }

    @objc private func toggleFoldTest(_ sender: UIButton) {
        usesTestAngle.toggle()
        foldJumpDetector.reset()
        foldTestControls.isHidden = !usesTestAngle
        sender.setTitle(usesTestAngle ? "Fold test: on — use test slider" : "Fold test: off — use device hinge", for: .normal)
        if usesTestAngle {
            testAngleChanged()
        } else {
            handleHingeAngle(lastDeviceAngle)
        }
    }

    @objc private func testAngleChanged() {
        handleHingeAngle(CGFloat(foldTestSlider.value) * .pi / 180)
    }

    @objc private func useTestPreset(_ sender: UIButton) {
        foldTestSlider.value = Float(sender.tag)
        testAngleChanged()
    }
    #endif

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
