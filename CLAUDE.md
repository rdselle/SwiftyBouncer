# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the project
xcodebuild -project SwiftyBouncer.xcodeproj -scheme SwiftyBouncer

# Build for Debug configuration
xcodebuild -project SwiftyBouncer.xcodeproj -scheme SwiftyBouncer -configuration Debug

# Build for Release configuration
xcodebuild -project SwiftyBouncer.xcodeproj -scheme SwiftyBouncer -configuration Release

# Clean build
xcodebuild -project SwiftyBouncer.xcodeproj clean

# Open in Xcode
open SwiftyBouncer.xcodeproj
```

## Project Overview

SwiftyBouncer is a native iOS physics simulation game built with UIKit Dynamics. Users create blocks that interact with physics-based gravity (controlled by device accelerometer), collide with each other, and fragment when collisions exceed a speed threshold.

**Target:** iOS 11.4+, Swift 4.0

## Architecture

The app follows an MVC pattern with three main components:

### BouncerVC (Main Game Controller)
- Central hub managing all game logic and physics simulation
- Implements `UICollisionBehaviorDelegate` for collision handling
- Uses `CMMotionManager` for accelerometer-driven gravity direction
- Physics stack: `UIDynamicAnimator` coordinating `UICollisionBehavior`, `UIGravityBehavior`, `UIDynamicItemBehavior`, `UISnapBehavior`, and `UIPushBehavior`

### BlockView (Interactive Block)
- Custom UIView subclass with touch handling
- Communicates with BouncerVC via `BlockViewDelegate` protocol
- `splitViewAndDestroy()` fragments the block into 4 quadrants on destruction

### Constants
- Game physics tuning values (snap damping, collision speed thresholds, elasticity, block dimensions)
- `ViewType` enum for distinguishing between BlockView and fragment UIView instances

## Key Game Mechanics

1. Touch creates new blocks; dragging snaps block to finger position
2. Device tilt controls gravity direction via accelerometer (0.1s update interval)
3. Blocks collide with screen boundaries and each other
4. Collisions exceeding `SPEED_DIFFERENTIAL_OF_DESTRUCTION` (250.0) trigger fragmentation
5. Fragments have 2-second immunity period before they can be destroyed

## Dependencies

No external dependencies. Uses only UIKit and CoreMotion frameworks.
