//
//  BlockView.swift
//  SwiftyBouncer
//
//  Created by Robert Sellers on 8/14/18.
//  Copyright © 2018 Robert Sellers. All rights reserved.
//

import UIKit

protocol BlockViewDelegate: class {
    func addAttachFor(view: BlockView, touches: Set<UITouch>)
    func updatePositionFor(view: BlockView, touches: Set<UITouch>)
    func removeAttach()
}

class BlockView: UIView {
    var latestBlock = true
    weak var blockViewDelegate: BlockViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        blockViewDelegate?.addAttachFor(view: self, touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        blockViewDelegate?.updatePositionFor(view: self, touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        blockViewDelegate?.removeAttach()
    }
    
    func splitViewAndDestroy() -> [UIView] {
        let corner1 = CGRect(x: frame.minX, y: frame.origin.y, width: blockSize.width / 2.0, height: blockSize.height / 2.0)
        let corner2 = CGRect(x: frame.midX, y: frame.origin.y, width: blockSize.width / 2.0, height: blockSize.height / 2.0)
        let corner3 = CGRect(x: frame.minX, y: frame.midY, width: blockSize.width / 2.0, height: blockSize.height / 2.0)
        let corner4 = CGRect(x: frame.midX, y: frame.midY, width: blockSize.width / 2.0, height: blockSize.height / 2.0)
        
        let view1 = UIView(frame: corner1)
        view1.backgroundColor = backgroundColor
        superview?.addSubview(view1)
        
        let view2 = UIView(frame: corner2)
        view2.backgroundColor = backgroundColor
        superview?.addSubview(view2)
        
        let view3 = UIView(frame: corner3)
        view3.backgroundColor = backgroundColor
        superview?.addSubview(view3)
        
        let view4 = UIView(frame: corner4)
        view4.backgroundColor = backgroundColor
        superview?.addSubview(view4)
        
        removeFromSuperview()
        
        return [view1, view2, view3, view4]
    }
}
