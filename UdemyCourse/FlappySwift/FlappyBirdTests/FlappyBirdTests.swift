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
}
