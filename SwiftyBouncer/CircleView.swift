//
//  CircleView.swift
//  SwiftyBouncer
//
//  Created by Claude Code on 12/16/24.
//  Copyright © 2024 Robert Sellers. All rights reserved.
//

import UIKit

protocol CircleViewDelegate: class {
    func addAttachFor(circleView: CircleView, touches: Set<UITouch>)
    func updatePositionFor(circleView: CircleView, touches: Set<UITouch>)
    func removeAttach()
}

class CircleView: UIView {
    var latestCircle = true
    weak var circleViewDelegate: CircleViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircularAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCircularAppearance()
    }

    private func setupCircularAppearance() {
        layer.cornerRadius = frame.width / 2.0
        clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update corner radius if frame changes
        layer.cornerRadius = frame.width / 2.0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        circleViewDelegate?.addAttachFor(circleView: self, touches: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        circleViewDelegate?.updatePositionFor(circleView: self, touches: touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        circleViewDelegate?.removeAttach()
    }

    func splitViewAndDestroy() -> [UIView] {
        let fragmentSize = CIRCLE_SIZE.width / 2.0
        let fragmentRadius = fragmentSize / 2.0

        // Create 4 smaller circles positioned around the center
        // Offset from center to position fragments in quadrants
        let offset = fragmentRadius / 2.0

        let circle1Frame = CGRect(x: frame.minX + offset, y: frame.minY + offset, width: fragmentSize, height: fragmentSize)
        let circle2Frame = CGRect(x: frame.midX - offset, y: frame.minY + offset, width: fragmentSize, height: fragmentSize)
        let circle3Frame = CGRect(x: frame.minX + offset, y: frame.midY - offset, width: fragmentSize, height: fragmentSize)
        let circle4Frame = CGRect(x: frame.midX - offset, y: frame.midY - offset, width: fragmentSize, height: fragmentSize)

        let circle1 = createCircularFragment(frame: circle1Frame)
        let circle2 = createCircularFragment(frame: circle2Frame)
        let circle3 = createCircularFragment(frame: circle3Frame)
        let circle4 = createCircularFragment(frame: circle4Frame)

        superview?.addSubview(circle1)
        superview?.addSubview(circle2)
        superview?.addSubview(circle3)
        superview?.addSubview(circle4)

        removeFromSuperview()

        return [circle1, circle2, circle3, circle4]
    }

    private func createCircularFragment(frame: CGRect) -> UIView {
        let fragment = UIView(frame: frame)
        fragment.backgroundColor = backgroundColor
        fragment.layer.cornerRadius = frame.width / 2.0
        fragment.clipsToBounds = true
        return fragment
    }
}
