//
//  FlappyBirdTests.swift
//  FlappyBirdTests
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import XCTest
import SpriteKit
@testable import FlappyBird

@MainActor
class FlappyBirdTests: XCTestCase {

    func testApplicationLaunchesWithSceneLifecycleAndProgrammaticGameController() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.delegate is SceneDelegate })
        let delegate = try XCTUnwrap(scene.delegate as? SceneDelegate)
        let window = try XCTUnwrap(delegate.window)
        let controller = try XCTUnwrap(window.rootViewController as? GameViewController)

        XCTAssertTrue(window.windowScene === scene)
        XCTAssertNil(scene.session.configuration.storyboard)
        XCTAssertFalse(window.isHidden)
        XCTAssertNil(Bundle.main.object(forInfoDictionaryKey: "UIMainStoryboardFile"))
        XCTAssertNil(controller.storyboard)
        controller.loadViewIfNeeded()
        let skView = try XCTUnwrap(controller.view as? SKView)
        XCTAssertTrue(skView.scene is GameScene)
        XCTAssertTrue(controller.prefersStatusBarHidden)
    }

    func testGameControllerCreatesAndKeepsItsScene() throws {
        let controller = GameViewController()
        controller.loadViewIfNeeded()
        let skView = try XCTUnwrap(controller.view as? SKView)
        let scene = try XCTUnwrap(skView.scene as? GameScene)

        XCTAssertEqual(scene.scaleMode, .aspectFill)
        XCTAssertTrue(skView.ignoresSiblingOrder)
        XCTAssertTrue(skView.showsFPS)
        XCTAssertTrue(skView.showsNodeCount)
        XCTAssertNotNil(scene.bird)
        XCTAssertNotNil(scene.scoreLabelNode)

        skView.frame = CGRect(x: 0, y: 0, width: 844, height: 390)
        skView.setNeedsLayout()
        skView.layoutIfNeeded()
        XCTAssertTrue(skView.scene === scene)
        skView.presentScene(nil)
    }
    func testFoldTriggersOnceAfterCrossingBothThresholds() {
        var detector = FoldJumpDetector()
        let angles: [CGFloat] = [80, 130, 110, 95, 85, 80, 89, 100, 119, 85, 150, 70]
        let triggered = angles.map { detector.consume(angleInRadians: $0 * .pi / 180) }
        XCTAssertEqual(triggered, [false, false, false, false, true, false, false, false, false, false, false, true])
    }

    func testFoldThresholdsAreStrict() {
        var detector = FoldJumpDetector()
        XCTAssertFalse(detector.consume(angleInRadians: 120 * .pi / 180))
        XCTAssertFalse(detector.consume(angleInRadians: 80 * .pi / 180))
        XCTAssertFalse(detector.consume(angleInRadians: 121 * .pi / 180))
        XCTAssertFalse(detector.consume(angleInRadians: .pi / 2))
        XCTAssertTrue(detector.consume(angleInRadians: 89 * .pi / 180))
    }

    func testMissingOrInvalidHingeClearsArmedGesture() {
        for angle: CGFloat? in [nil, .nan, .infinity, -1, .pi + 1] {
            var detector = FoldJumpDetector()
            XCTAssertFalse(detector.consume(angleInRadians: .pi))
            XCTAssertFalse(detector.consume(angleInRadians: angle))
            XCTAssertFalse(detector.consume(angleInRadians: .pi / 4))
        }
    }

    func testHingeInputAppliesImpulseOnlyOnceAndCanRestart() throws {
        let controller = GameViewController()
        controller.loadViewIfNeeded()
        let skView = try XCTUnwrap(controller.view as? SKView)
        let scene = try XCTUnwrap(skView.scene as? GameScene)
        defer { skView.presentScene(nil) }
        let body = try XCTUnwrap(scene.bird.physicsBody)
        scene.isPaused = true
        body.velocity = CGVector(dx: 0, dy: -100)

        controller.handleHingeAngle(130 * .pi / 180)
        XCTAssertEqual(body.velocity.dy, -100)
        controller.handleHingeAngle(80 * .pi / 180)
        XCTAssertGreaterThan(body.velocity.dy, 0)
        body.velocity = .zero
        controller.handleHingeAngle(70 * .pi / 180)
        XCTAssertEqual(body.velocity.dy, 0)

        scene.moving.speed = 0
        scene.canRestart = false
        controller.handleHingeAngle(130 * .pi / 180)
        controller.handleHingeAngle(80 * .pi / 180)
        XCTAssertEqual(scene.moving.speed, 0)
        scene.canRestart = true
        controller.handleHingeAngle(130 * .pi / 180)
        controller.handleHingeAngle(80 * .pi / 180)
        XCTAssertGreaterThan(scene.moving.speed, 0)
        XCTAssertEqual(scene.score, 0)
    }

    func testControllerRegistersPublicHingeInteraction() {
        if #available(iOS 27.1, *) {
            let controller = GameViewController()
            controller.loadViewIfNeeded()
            XCTAssertEqual(controller.view.interactions.filter { $0 is UIHingeInteraction }.count, 1)
            (controller.view as? SKView)?.presentScene(nil)
        }
    }
    #if DEBUG && targetEnvironment(simulator)
    func testSimulatorPanelRoutesPresetsThroughFoldInput() throws {
        let controller = GameViewController()
        controller.loadViewIfNeeded()
        let skView = try XCTUnwrap(controller.view as? SKView)
        defer { skView.presentScene(nil) }

        func descendants(of view: UIView) -> [UIView] {
            return view.subviews.flatMap { [$0] + descendants(of: $0) }
        }
        let views = descendants(of: skView)
        let buttons = views.compactMap { $0 as? UIButton }
        let toggle = try XCTUnwrap(buttons.first { $0.currentTitle?.hasPrefix("Fold test:") == true })
        let close = try XCTUnwrap(buttons.first { $0.tag == 80 })
        let open = try XCTUnwrap(buttons.first { $0.tag == 130 })
        let label = try XCTUnwrap(views.first { $0.accessibilityIdentifier == "foldStatus" } as? UILabel)
        let slider = try XCTUnwrap(views.compactMap { $0 as? UISlider }.first)

        toggle.sendActions(for: .touchUpInside)
        XCTAssertTrue(label.text?.contains("Test: 130° · armed") == true)
        close.sendActions(for: .touchUpInside)
        XCTAssertTrue(label.text?.contains("folds: 1") == true)
        close.sendActions(for: .touchUpInside)
        XCTAssertTrue(label.text?.contains("folds: 1") == true)
        open.sendActions(for: .touchUpInside)
        slider.value = 85
        slider.sendActions(for: .valueChanged)
        XCTAssertTrue(label.text?.contains("Test: 85°") == true)
        XCTAssertTrue(label.text?.contains("folds: 2") == true)
        toggle.sendActions(for: .touchUpInside)
        XCTAssertTrue(label.text?.hasPrefix("Device:") == true)
    }
    #endif
}
