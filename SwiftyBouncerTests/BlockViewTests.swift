//
//  BlockViewTests.swift
//  SwiftyBouncerTests
//
//  Created by Claude Code on 12/16/24.
//  Copyright © 2024 Robert Sellers. All rights reserved.
//

import XCTest
@testable import SwiftyBouncer

// MARK: - Mock Delegate

class MockBlockViewDelegate: BlockViewDelegate {
    var addAttachCalled = false
    var updatePositionCalled = false
    var removeAttachCalled = false

    var lastBlockView: BlockView?
    var lastTouches: Set<UITouch>?

    func addAttachFor(blockView: BlockView, touches: Set<UITouch>) {
        addAttachCalled = true
        lastBlockView = blockView
        lastTouches = touches
    }

    func updatePositionFor(blockView: BlockView, touches: Set<UITouch>) {
        updatePositionCalled = true
        lastBlockView = blockView
        lastTouches = touches
    }

    func removeAttach() {
        removeAttachCalled = true
    }

    func reset() {
        addAttachCalled = false
        updatePositionCalled = false
        removeAttachCalled = false
        lastBlockView = nil
        lastTouches = nil
    }
}

// MARK: - BlockView Tests

class BlockViewTests: XCTestCase {

    var sut: BlockView!
    var mockDelegate: MockBlockViewDelegate!
    var containerView: UIView!

    override func setUp() {
        super.setUp()
        sut = BlockView(frame: CGRect(x: 100, y: 100, width: BLOCK_SIZE.width, height: BLOCK_SIZE.height))
        mockDelegate = MockBlockViewDelegate()
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 600))
    }

    override func tearDown() {
        sut = nil
        mockDelegate = nil
        containerView = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_latestBlockIsTrue() {
        XCTAssertTrue(sut.latestBlock, "New BlockView should have latestBlock set to true")
    }

    func testInitialState_delegateIsNil() {
        XCTAssertNil(sut.blockViewDelegate, "New BlockView should have nil delegate")
    }

    func testInitialState_frameIsSetCorrectly() {
        let expectedFrame = CGRect(x: 100, y: 100, width: BLOCK_SIZE.width, height: BLOCK_SIZE.height)
        XCTAssertEqual(sut.frame, expectedFrame, "BlockView frame should match initialization")
    }

    // MARK: - Delegate Property Tests

    func testDelegate_canBeSet() {
        sut.blockViewDelegate = mockDelegate
        XCTAssertNotNil(sut.blockViewDelegate, "Delegate should be settable")
    }

    func testDelegate_isWeakReference() {
        var delegate: MockBlockViewDelegate? = MockBlockViewDelegate()
        sut.blockViewDelegate = delegate
        XCTAssertNotNil(sut.blockViewDelegate, "Delegate should be set")

        delegate = nil
        XCTAssertNil(sut.blockViewDelegate, "Delegate should be nil after deallocation (weak reference)")
    }

    // MARK: - latestBlock Property Tests

    func testLatestBlock_canBeSetToFalse() {
        sut.latestBlock = false
        XCTAssertFalse(sut.latestBlock, "latestBlock should be settable to false")
    }

    func testLatestBlock_canBeToggledBackToTrue() {
        sut.latestBlock = false
        sut.latestBlock = true
        XCTAssertTrue(sut.latestBlock, "latestBlock should be togglable back to true")
    }

    // MARK: - Touch Handling Tests (with delegate)

    func testTouchesBegan_callsDelegateAddAttach() {
        sut.blockViewDelegate = mockDelegate

        sut.touchesBegan(Set<UITouch>(), with: nil)

        XCTAssertTrue(mockDelegate.addAttachCalled, "touchesBegan should call delegate's addAttachFor")
    }

    func testTouchesBegan_passesCorrectBlockView() {
        sut.blockViewDelegate = mockDelegate

        sut.touchesBegan(Set<UITouch>(), with: nil)

        XCTAssertIdentical(mockDelegate.lastBlockView, sut, "touchesBegan should pass self as blockView")
    }

    func testTouchesMoved_callsDelegateUpdatePosition() {
        sut.blockViewDelegate = mockDelegate

        sut.touchesMoved(Set<UITouch>(), with: nil)

        XCTAssertTrue(mockDelegate.updatePositionCalled, "touchesMoved should call delegate's updatePositionFor")
    }

    func testTouchesMoved_passesCorrectBlockView() {
        sut.blockViewDelegate = mockDelegate

        sut.touchesMoved(Set<UITouch>(), with: nil)

        XCTAssertIdentical(mockDelegate.lastBlockView, sut, "touchesMoved should pass self as blockView")
    }

    func testTouchesEnded_callsDelegateRemoveAttach() {
        sut.blockViewDelegate = mockDelegate

        sut.touchesEnded(Set<UITouch>(), with: nil)

        XCTAssertTrue(mockDelegate.removeAttachCalled, "touchesEnded should call delegate's removeAttach")
    }

    // MARK: - Touch Handling Tests (without delegate - edge cases)

    func testTouchesBegan_withNilDelegate_doesNotCrash() {
        sut.blockViewDelegate = nil

        // Should not crash
        sut.touchesBegan(Set<UITouch>(), with: nil)

        // If we reach here, test passes
        XCTAssertNil(sut.blockViewDelegate)
    }

    func testTouchesMoved_withNilDelegate_doesNotCrash() {
        sut.blockViewDelegate = nil

        // Should not crash
        sut.touchesMoved(Set<UITouch>(), with: nil)

        XCTAssertNil(sut.blockViewDelegate)
    }

    func testTouchesEnded_withNilDelegate_doesNotCrash() {
        sut.blockViewDelegate = nil

        // Should not crash
        sut.touchesEnded(Set<UITouch>(), with: nil)

        XCTAssertNil(sut.blockViewDelegate)
    }

    // MARK: - splitViewAndDestroy Tests (Happy Path)

    func testSplitViewAndDestroy_returnsFourViews() {
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        XCTAssertEqual(fragments.count, 4, "splitViewAndDestroy should return exactly 4 views")
    }

    func testSplitViewAndDestroy_fragmentsAreHalfSize() {
        containerView.addSubview(sut)
        let expectedWidth = BLOCK_SIZE.width / 2.0
        let expectedHeight = BLOCK_SIZE.height / 2.0

        let fragments = sut.splitViewAndDestroy()

        for (index, fragment) in fragments.enumerated() {
            XCTAssertEqual(fragment.frame.width, expectedWidth, "Fragment \(index) width should be half of BLOCK_SIZE")
            XCTAssertEqual(fragment.frame.height, expectedHeight, "Fragment \(index) height should be half of BLOCK_SIZE")
        }
    }

    func testSplitViewAndDestroy_fragmentsHaveCorrectPositions() {
        let frame = CGRect(x: 100, y: 200, width: BLOCK_SIZE.width, height: BLOCK_SIZE.height)
        sut = BlockView(frame: frame)
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        // Top-left corner
        XCTAssertEqual(fragments[0].frame.minX, frame.minX, "Fragment 0 should be at left edge")
        XCTAssertEqual(fragments[0].frame.minY, frame.minY, "Fragment 0 should be at top edge")

        // Top-right corner
        XCTAssertEqual(fragments[1].frame.minX, frame.midX, "Fragment 1 should be at horizontal center")
        XCTAssertEqual(fragments[1].frame.minY, frame.minY, "Fragment 1 should be at top edge")

        // Bottom-left corner
        XCTAssertEqual(fragments[2].frame.minX, frame.minX, "Fragment 2 should be at left edge")
        XCTAssertEqual(fragments[2].frame.minY, frame.midY, "Fragment 2 should be at vertical center")

        // Bottom-right corner
        XCTAssertEqual(fragments[3].frame.minX, frame.midX, "Fragment 3 should be at horizontal center")
        XCTAssertEqual(fragments[3].frame.minY, frame.midY, "Fragment 3 should be at vertical center")
    }

    func testSplitViewAndDestroy_fragmentsInheritBackgroundColor() {
        let testColor = UIColor.red
        sut.backgroundColor = testColor
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        for (index, fragment) in fragments.enumerated() {
            XCTAssertEqual(fragment.backgroundColor, testColor, "Fragment \(index) should inherit background color")
        }
    }

    func testSplitViewAndDestroy_fragmentsAddedToSuperview() {
        containerView.addSubview(sut)
        let initialSubviewCount = containerView.subviews.count

        let fragments = sut.splitViewAndDestroy()

        // Original view removed, 4 fragments added
        XCTAssertEqual(containerView.subviews.count, initialSubviewCount - 1 + 4, "Container should have 4 new subviews minus the removed original")

        for fragment in fragments {
            XCTAssertTrue(containerView.subviews.contains(fragment), "Fragment should be added to container")
        }
    }

    func testSplitViewAndDestroy_removesBlockViewFromSuperview() {
        containerView.addSubview(sut)
        XCTAssertNotNil(sut.superview, "BlockView should have superview before split")

        _ = sut.splitViewAndDestroy()

        XCTAssertNil(sut.superview, "BlockView should be removed from superview after split")
        XCTAssertFalse(containerView.subviews.contains(sut), "Container should not contain original BlockView")
    }

    // MARK: - splitViewAndDestroy Edge Cases

    func testSplitViewAndDestroy_withNoSuperview_returnsFragments() {
        // BlockView not added to any superview
        XCTAssertNil(sut.superview)

        let fragments = sut.splitViewAndDestroy()

        XCTAssertEqual(fragments.count, 4, "Should still return 4 fragments even without superview")
    }

    func testSplitViewAndDestroy_withNoSuperview_fragmentsNotAddedAnywhere() {
        XCTAssertNil(sut.superview)

        let fragments = sut.splitViewAndDestroy()

        for fragment in fragments {
            XCTAssertNil(fragment.superview, "Fragments should have no superview when original had none")
        }
    }

    func testSplitViewAndDestroy_withNilBackgroundColor_fragmentsHaveNilColor() {
        sut.backgroundColor = nil
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        for fragment in fragments {
            XCTAssertNil(fragment.backgroundColor, "Fragments should have nil background when original was nil")
        }
    }

    func testSplitViewAndDestroy_atOrigin_hasCorrectPositions() {
        sut = BlockView(frame: CGRect(x: 0, y: 0, width: BLOCK_SIZE.width, height: BLOCK_SIZE.height))
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        XCTAssertEqual(fragments[0].frame.origin, CGPoint(x: 0, y: 0), "Top-left fragment at origin")
        XCTAssertEqual(fragments[1].frame.origin.x, BLOCK_SIZE.width / 2.0, "Top-right fragment x position")
        XCTAssertEqual(fragments[2].frame.origin.y, BLOCK_SIZE.height / 2.0, "Bottom-left fragment y position")
    }

    func testSplitViewAndDestroy_withNegativeOrigin_hasCorrectPositions() {
        sut = BlockView(frame: CGRect(x: -50, y: -50, width: BLOCK_SIZE.width, height: BLOCK_SIZE.height))
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        XCTAssertEqual(fragments[0].frame.minX, -50, "Top-left fragment should respect negative x")
        XCTAssertEqual(fragments[0].frame.minY, -50, "Top-left fragment should respect negative y")
    }

    func testSplitViewAndDestroy_withLargeCoordinates_hasCorrectPositions() {
        let largeX: CGFloat = 10000
        let largeY: CGFloat = 10000
        sut = BlockView(frame: CGRect(x: largeX, y: largeY, width: BLOCK_SIZE.width, height: BLOCK_SIZE.height))
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        XCTAssertEqual(fragments[0].frame.minX, largeX, "Should handle large coordinates")
        XCTAssertEqual(fragments[0].frame.minY, largeY, "Should handle large coordinates")
    }

    // MARK: - splitViewAndDestroy with various background colors

    func testSplitViewAndDestroy_withClearColor_fragmentsAreClear() {
        sut.backgroundColor = .clear
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        for fragment in fragments {
            XCTAssertEqual(fragment.backgroundColor, .clear)
        }
    }

    func testSplitViewAndDestroy_withAlphaColor_fragmentsPreserveAlpha() {
        let colorWithAlpha = UIColor.blue.withAlphaComponent(0.5)
        sut.backgroundColor = colorWithAlpha
        containerView.addSubview(sut)

        let fragments = sut.splitViewAndDestroy()

        for fragment in fragments {
            XCTAssertEqual(fragment.backgroundColor, colorWithAlpha, "Should preserve color alpha")
        }
    }

    // MARK: - Multiple Operations Tests

    func testMultipleTouchSequences_delegateCalledCorrectly() {
        sut.blockViewDelegate = mockDelegate

        // First touch sequence
        sut.touchesBegan(Set<UITouch>(), with: nil)
        sut.touchesMoved(Set<UITouch>(), with: nil)
        sut.touchesEnded(Set<UITouch>(), with: nil)

        XCTAssertTrue(mockDelegate.addAttachCalled)
        XCTAssertTrue(mockDelegate.updatePositionCalled)
        XCTAssertTrue(mockDelegate.removeAttachCalled)

        // Reset and do another sequence
        mockDelegate.reset()

        sut.touchesBegan(Set<UITouch>(), with: nil)
        XCTAssertTrue(mockDelegate.addAttachCalled)
        XCTAssertFalse(mockDelegate.updatePositionCalled)
        XCTAssertFalse(mockDelegate.removeAttachCalled)
    }

    func testDelegateChange_midTouchSequence() {
        let firstDelegate = MockBlockViewDelegate()
        let secondDelegate = MockBlockViewDelegate()

        sut.blockViewDelegate = firstDelegate
        sut.touchesBegan(Set<UITouch>(), with: nil)

        XCTAssertTrue(firstDelegate.addAttachCalled)
        XCTAssertFalse(secondDelegate.addAttachCalled)

        // Change delegate mid-sequence
        sut.blockViewDelegate = secondDelegate
        sut.touchesMoved(Set<UITouch>(), with: nil)

        XCTAssertFalse(firstDelegate.updatePositionCalled)
        XCTAssertTrue(secondDelegate.updatePositionCalled)
    }
}
