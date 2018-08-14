//
//  Constants.swift
//  SwiftyBouncer
//
//  Created by Robert Sellers on 8/14/18.
//  Copyright © 2018 Robert Sellers. All rights reserved.
//

import UIKit

enum ViewType {
    case UIView
    case BlockView
    case Unknown
}

let snapDamping: CGFloat = 0.5
let anchorFrequency: CGFloat = 0.8
let distanceForNewBlock: Float = 110.0
let speedDifferentialOfDestruction: CGFloat = 250.0
let TimeDifferentialOfDestruction: TimeInterval = 2.0
let smallBlockDensity: CGFloat = 3.0
let elasticity: CGFloat = 0.5

let blockSize = CGSize(width: 60.0, height: 60.0)
let initalCenter = CGPoint(x: 75.0, y: 80.0)
