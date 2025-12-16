//
//  BouncerVC.swift
//  SwiftyBouncer
//
//  Created by Robert Sellers on 8/14/18.
//  Copyright © 2018 Robert Sellers. All rights reserved.
//

import UIKit
import CoreMotion

class BouncerVC: UIViewController, UICollisionBehaviorDelegate, BlockViewDelegate {
    var animator = UIDynamicAnimator()
    let motionManager = CMMotionManager()
    
    let collider = UICollisionBehavior()
    let gravity = UIGravityBehavior()
    let elastic = UIDynamicItemBehavior()
    let density = UIDynamicItemBehavior()
    var snap: UISnapBehavior?
    var touchSnap: UISnapBehavior?
    var push: UIPushBehavior?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var blocks = [BlockView]()
    var smallBlocksImmune = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collider.translatesReferenceBoundsIntoBoundary = true
        collider.collisionDelegate = self
        elastic.elasticity = ELASTICITY
        density.density = SMALL_BLOCK_DENSITY
        
        animator = UIDynamicAnimator(referenceView: view)
        animator.addBehavior(collider)
        animator.addBehavior(gravity)
        animator.addBehavior(elastic)
        animator.addBehavior(density)
        
        motionManager.accelerometerUpdateInterval = 0.1
        
        start()
    }
    
    func start() {
        if blocks.isEmpty {
            createNewBlock(at: INITIAL_CENTER)
        }
        
        if motionManager.isAccelerometerActive {
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (accelerometerData, error) in
                guard let self = self else { return }
                let x = CGFloat(accelerometerData?.acceleration.x ?? 0.0 / 5.0)
                let y = CGFloat(accelerometerData?.acceleration.y ?? 0.0 / 5.0)
                let orientation = self.currentInterfaceOrientation
                switch orientation {
                case .landscapeRight:
                    self.gravity.gravityDirection = CGVector(dx: -y, dy: -x)
                case .landscapeLeft:
                    self.gravity.gravityDirection = CGVector(dx: y, dy: x)
                case .portrait:
                    self.gravity.gravityDirection = CGVector(dx: x, dy: -y)
                case .portraitUpsideDown:
                    self.gravity.gravityDirection = CGVector(dx: -x, dy: y)
                case .unknown:
                    self.gravity.gravityDirection = CGVector(dx: 0.0, dy: 0.0)
                @unknown default:
                    self.gravity.gravityDirection = CGVector(dx: x, dy: -y)
                }
            }
        }
    }
    
    // MARK: block creation methods
    
    func createNewBlock(at location: CGPoint) {
        let newBlock = addBlock(at: location)
        newBlock.blockViewDelegate = self
        collider.addItem(newBlock)
        gravity.addItem(newBlock)
        elastic.addItem(newBlock)
        blocks.append(newBlock)
        
        if let block = blocks.last {
            snap = UISnapBehavior(item: block, snapTo: INITIAL_CENTER)
            snap?.damping = SNAP_DAMPING
            animator.addBehavior(snap ?? UIDynamicBehavior())
        }
    }
    
    func addBlock(at location: CGPoint) -> BlockView {
        let blockFrame = CGRect(x: location.x - BLOCK_SIZE.width / 2.0, y: location.y - BLOCK_SIZE.height / 2.0, width: BLOCK_SIZE.width, height: BLOCK_SIZE.height)
        let block = BlockView(frame: blockFrame)
        block.backgroundColor = randomColor()
        view.addSubview(block)
        return block
    }
    
    func shouldCreateNewBlock(at blockCenter: CGPoint, touchLocation: CGPoint) -> Bool {
        let result = pythagorean(p: CGPoint(x: touchLocation.x - blockCenter.x, y: touchLocation.y - blockCenter.y))
        return result > DISTANCE_FOR_NEW_BLOCK
    }
    
    // MARK: BlockView delegate methods
    
    func addAttachFor(blockView: BlockView, touches: Set<UITouch>) {
        let touchArray = [UITouch](touches)
        guard let touch = touchArray.first else {
            return
        }
        
        let location = touch.location(in: view)
        touchSnap = UISnapBehavior(item: blockView, snapTo: location)
        animator.addBehavior(touchSnap ?? UIDynamicBehavior())
    }
    
    func updatePositionFor(blockView: BlockView, touches: Set<UITouch>) {
        let touchArray = [UITouch](touches)
        guard let touch = touchArray.first else {
            return
        }
        
        let location = touch.location(in: view)
        animator.removeBehavior(touchSnap ?? UIDynamicBehavior())
        touchSnap = UISnapBehavior(item: blockView, snapTo: location)
        animator.addBehavior(touchSnap ?? UIDynamicBehavior())
        
        if blockView.latestBlock && shouldCreateNewBlock(at: blockView.center, touchLocation: location){
            blockView.latestBlock = false
            animator.removeBehavior(snap ?? UIDynamicBehavior())
            createNewBlock(at: blockView.center)
        }
    }
    
    func removeAttach() {
        animator.removeBehavior(touchSnap ?? UIDynamicBehavior())
    }
    
    // MARK: collision handling
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        let item1Type = determineViewType(item: item1)
        let item2Type = determineViewType(item: item2)
        
        if item1Type == .BlockView && item2Type == .BlockView {
            guard let block1 = item1 as? BlockView,
                let block2 = item2 as? BlockView,
                !(block1.latestBlock || block2.latestBlock) else {
                    return
            }
            
            let item1Speed = CGFloat(pythagorean(p: elastic.linearVelocity(for: item1)))
            let item2Speed = CGFloat(pythagorean(p: elastic.linearVelocity(for: item2)))
            
            if item1Speed > item2Speed + SPEED_DIFFERENTIAL_OF_DESTRUCTION {
                destroy(block: block2, behavior: behavior)
            } else if item1Speed + SPEED_DIFFERENTIAL_OF_DESTRUCTION < item2Speed {
                destroy(block: block1, behavior: behavior)
            }
        } else if item1Type == .BlockView {
            guard let view2 = item2 as? UIView else {
                return
            }
            
            destroy(view: view2, behavior: behavior)
        } else if item2Type == .BlockView {
            guard let view1 = item1 as? UIView else {
                return
            }
            
            destroy(view: view1, behavior: behavior)
        } else {
            // if both items are not a block view, let the animator handle the collision and do nothing else
        }
    }
    
    func destroy(block: BlockView, behavior: UICollisionBehavior) {
        guard let blockIndex = blocks.firstIndex(of: block) else {
            return
        }
        
        let viewsToAdd = block.splitViewAndDestroy()
        behavior.removeItem(block)
        blocks.remove(at: blockIndex)
        addToAnimatorBehaviors(views: viewsToAdd)
    }
    
    func destroy(view: UIView, behavior: UICollisionBehavior) {
        if !smallBlocksImmune {
            view.removeFromSuperview()
            behavior.removeItem(view)
            density.removeItem(view)
            gravity.removeItem(view)
            elastic.removeItem(view)
        }
    }
    
    // MARK: set up split BlockViews
    
    func addToAnimatorBehaviors(views: [UIView]) {
        for newView in views {
            collider.addItem(newView)
            gravity.addItem(newView)
            elastic.addItem(newView)
            density.addItem(newView)
            configurePush(view: newView)
        }
        
        smallBlocksImmune = true
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.smallBlocksImmune = false
        }
    }
    
    func configurePush(view: UIView) {
        let angle = CGFloat(Double(arc4random() % 360) * .pi / 180.0)
        let magnitude = CGFloat(Double(arc4random() % 2) + 0.5) * SMALL_BLOCK_DENSITY
        
        push = UIPushBehavior(items: [view], mode: .instantaneous)
        push?.setAngle(angle, magnitude: magnitude)
        animator.addBehavior(push ?? UIDynamicBehavior())
        push?.active = true
    }
    
    // MARK: miscellaneous

    var currentInterfaceOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return view.window?.windowScene?.interfaceOrientation ?? .unknown
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }

    func pythagorean(p: CGPoint) -> Float {
        return sqrtf((powf(Float(p.x), 2) + powf(Float(p.y), 2)))
    }
    
    func randomColor() -> UIColor {
        let red = CGFloat(arc4random() % 200) / 200.0
        let green = CGFloat(arc4random() % 200) / 200.0
        let blue = CGFloat(arc4random() % 200) / 200.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func determineViewType(item: UIDynamicItem) -> ViewType {
        if let _ = item as? BlockView {
            return .BlockView
        } else if let _ = item as? UIView {
            return .UIView
        } else {
            return .Unknown
        }
    }
}

