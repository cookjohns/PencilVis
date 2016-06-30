//
//  CircleGestureRecognizer.swift
//  MatchItUp
//
//  Created by John Cook on 6/21/16.
//  Copyright © 2016 raywenderlich. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class CircleGestureRecognizer: UIGestureRecognizer {
  
  private var touchedPoints = [CGPoint]() // point history
  var fitResult = CircleResult() // info about how circle-like the path is
  var tolerance: CGFloat = 0.2    // "perfect circle" tolerance
  var isCircle = false
  var path = CGPathCreateMutable()
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
    super.touchesBegan(touches, withEvent: event)
//    if (touches.count != 1) {
//      state = .Failed // cancel the gesture if more than one finger is involved
//    }
    state = .Began
    
    let window = view?.window
    if let touches = touches as? Set<UITouch>, loc = touches.first?.locationInView(window) {
      CGPathMoveToPoint(path, nil, loc.x, loc.y)
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
    super.touchesMoved(touches, withEvent: event)
    
    // don't process other touches if gesture has already failed
    if state == .Failed {
      return
    }
    
    // add points to array as window coordinates, then update state
    let window = view?.window
    if let touches = touches as? Set<UITouch>, loc = touches.first?.locationInView(window) {
      touchedPoints.append(loc)
      CGPathAddLineToPoint(path, nil, loc.x, loc.y)
      state = .Changed
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
    super.touchesEnded(touches, withEvent: event)
    
    // figure out if path was circle
    fitResult = fitCircle(touchedPoints)
    
    // check for points in the middle of the circle
    let hasInside = anyPointsInTheMiddle()
    
    let percentOverlap = calculateBoundingOverlap()
    isCircle = fitResult.error <= tolerance && !hasInside //&& percentOverlap > (1-tolerance)
    state = isCircle ? .Ended : .Failed // fail or end, based on isCircle
  }
  
  override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
    super.touchesCancelled(touches, withEvent: event)
    state = .Cancelled // sets state when touches are cancelled
  }
  
  override func reset() {
    super.reset()
    touchedPoints.removeAll(keepCapacity: true)
    path = CGPathCreateMutable()
    isCircle = false
    state = .Possible
  }
  
  private func anyPointsInTheMiddle() -> Bool {
    let fitInnerRadius = fitResult.radius / sqrt(2) * tolerance
    
    let innerBox = CGRect(
      x: fitResult.center.x - fitInnerRadius,
      y: fitResult.center.y - fitInnerRadius,
      width: 2 * fitInnerRadius,
      height: 2 * fitInnerRadius)
    
    var hasInside = false
    for point in touchedPoints {
      if innerBox.contains(point) {
        hasInside = true
        break
      }
    }
    return hasInside
  }
  
  private func calculateBoundingOverlap() -> CGFloat {
    let fitBoundingBox = CGRect(
      x: fitResult.center.x - fitResult.radius,
      y: fitResult.center.y - fitResult.radius,
      width: 2 * fitResult.radius,
      height: 2 * fitResult.radius)
    let pathBoundingBox = CGPathGetBoundingBox(path)
    
    let overlapRect = fitBoundingBox.intersect(pathBoundingBox)
    
    let overlapRectArea = overlapRect.width * overlapRect.height
    let circleBoxArea = fitBoundingBox.width * fitBoundingBox.height
    
    let percentOverlap = overlapRectArea / circleBoxArea
    return percentOverlap
  }
}
