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

let SNAP_DAMPING: CGFloat = 0.5
let DISTANCE_FOR_NEW_BLOCK: Float = 110.0
let SPEED_DIFFERENTIAL_OF_DESTRUCTION: CGFloat = 250.0
let TIME_DIFFERENTIAL_OF_DESTRUCTION: TimeInterval = 2.0
let SMALL_BLOCK_DENSITY: CGFloat = 3.0
let ELASTICITY: CGFloat = 0.5

let BLOCK_SIZE = CGSize(width: 60.0, height: 60.0)
let INITIAL_CENTER = CGPoint(x: 75.0, y: 80.0)
