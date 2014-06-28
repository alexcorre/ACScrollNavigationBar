//
//  ACScrollNavigationBar.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 6/26/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

let kNearZero = 0.000001

enum ACScrollNavigationBarState {
  case None
  case ScrollingUp
  case ScrollingDown
}

class ACScrollNavigationBar: UINavigationBar, UIGestureRecognizerDelegate {
  
  var scrollState = ACScrollNavigationBarState.None
  var lastContentOffsetY = 0.0
  var panGesture = UIPanGestureRecognizer()
  
  var scrollView: UIScrollView? {
    didSet {
      var defaultFrame = self.frame
      defaultFrame.origin.y = statusBarHeight()
      setFrame(defaultFrame, 1.0, true)
      
      // clean the panGesture and add it to the newly set scrollView
      panGesture.view?.removeGestureRecognizer(panGesture)
      scrollView?.addGestureRecognizer(panGesture)
    }
  }
  
  // MARK: Initializers
  
  init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  init(coder aDecoder: NSCoder!) {
    super.init(coder: aDecoder)
    self.setup()
  }
  
  func setup() {
    panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
    panGesture.delegate = self
    // TODO add notifications to rotation state recognizers?
  }
  
  // MARK: UIGestureRecognizerDelegate
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
    return true
  }
  
  // MARK: Gesture Handler
  
  func handlePan(gesture:UIPanGestureRecognizer) {
    // dont do anything if we dont have a scrollView
    if let myScrollView = self.scrollView {
      
      // return if the gesture is not attached to myScrollView
      if gesture.view !== myScrollView {
        return;
      }
      
      // TODO figure out what this does...
      if myScrollView.frame.size.height + (self.bounds.size.height * 2) >= myScrollView.contentSize.height {
        return
      }
      
      let contentOffsetY = myScrollView.contentOffset.y
      
      // Do nothing if we are scrolling the contentInset (padding)
      if contentOffsetY < -myScrollView.contentInset.top {
        return
      }
      
      // if the gesture just started...reset the state and store the last offset
      if gesture.state == UIGestureRecognizerState.Began {
        self.scrollState = ACScrollNavigationBarState.None
        self.lastContentOffsetY = contentOffsetY
        return
      }
      
      var deltaY = contentOffsetY - self.lastContentOffsetY;
      if deltaY < 0.0 {
        self.scrollState = ACScrollNavigationBarState.ScrollingDown;
      } else if deltaY > 0.0 {
        self.scrollState = ACScrollNavigationBarState.ScrollingUp;
      }
      
      var newFrame = self.frame
      var alpha = 1.0
      var statusBarHeight = self.statusBarHeight()
      var maxY = statusBarHeight
      var minY = maxY - CGRectGetHeight(newFrame) + 1.0
      // NOTE: plus 1px to prevent the navigation bar disappears in iOS < 7
      
      var isScrollingAndGestureEnded =
        (gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled) &&
        (self.scrollState == ACScrollNavigationBarState.ScrollingUp || self.scrollState == ACScrollNavigationBarState.ScrollingDown)
      
      if isScrollingAndGestureEnded {
        var contentOffsetYDelta = 0.0
        if self.scrollState == ACScrollNavigationBarState.ScrollingDown {
          contentOffsetYDelta = maxY - newFrame.origin.y
          newFrame.origin.y = maxY
          alpha = 1.0
        }
        else if self.scrollState == ACScrollNavigationBarState.ScrollingUp {
          contentOffsetYDelta = minY - newFrame.origin.y
          newFrame.origin.y = minY
          alpha = kNearZero
        }
        
        setFrame(newFrame, alpha, true)
        
        if !myScrollView.decelerating {
          var newContentOffset = CGPointMake(myScrollView.contentOffset.x, contentOffsetY - contentOffsetYDelta)
          myScrollView.setContentOffset(newContentOffset, animated: true)
        }

      } else {
        newFrame.origin.y -= deltaY;
        newFrame.origin.y = min(maxY, max(newFrame.origin.y, minY))
        
        alpha = (newFrame.origin.y - (minY + statusBarHeight)) / (maxY - (minY + statusBarHeight))
        alpha = max(kNearZero, alpha);
        
        setFrame(newFrame, alpha, false)
      }
      
      self.lastContentOffsetY = contentOffsetY
    }
  }
  
  // MARK: Helpers
  
  func resetToDefaultPosition(animated:Bool) {
    var defaultFrame = self.frame
    defaultFrame.origin.y = statusBarHeight()
    setFrame(defaultFrame, 1.0, animated)
  }
  
  func setFrame(newFrame:CGRect, _ alpha:CGFloat, _ animated:Bool) {
    // TODO make this work with/without animation...using closure?
    
    func animateNewFrame()  {
      var offsetY = CGRectGetMinY(newFrame) - CGRectGetMinY(self.frame)
      
      // set all subviews alphas to desired alpha...except background view which is (always?) first subview
      for subview in self.subviews as UIView[] {
        // NOTE === "triple equals" determines if the two object are the same instance
        var isBackgroundView = subview === self.subviews[0]
        var isViewHidden = subview.hidden || subview.alpha == 0.0
        
        if !(isBackgroundView || isViewHidden) {
          subview.alpha = alpha
        }
      }
      
      // move the navbar
      self.frame = newFrame
      
      // move the scrollviews parent view by the offset...check to make sure we have a scrollView first
      if let myScrollView = self.scrollView {
        var parentViewFrame = myScrollView.superview.frame
        parentViewFrame.origin.y += offsetY
        parentViewFrame.size.height -= offsetY
        myScrollView.superview.frame = parentViewFrame
      }
    }
    
    if animated {
      UIView.animateWithDuration(0.2, animations: animateNewFrame)
    } else {
      animateNewFrame()
    }

  }
  
  func statusBarHeight() -> CGFloat {
    let application = UIApplication.sharedApplication()
    let orientation = application.statusBarOrientation
    let statusBarFrame = application.statusBarFrame
    
    switch orientation {
    case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
      return statusBarFrame.height
    case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
      return statusBarFrame.width
    default:
      return statusBarFrame.height
    }
  }

}

/*! Extend UINavigationController to have a scrollNavigationBar property.
 *
 * TODO I dont think this is the best way to do this for the following reason...will discuss to see
 * best way to do this
 *
 * From Apple: “If you define an extension to add new functionality to an existing type, 
 * the new functionality will be available on all existing instances of that type, even if 
 * they were created before the extension was defined.”
 *
 * Excerpt From: Apple Inc. “The Swift Programming Language.” iBooks. 
 * https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewBook?id=881256329
 */
//extension UINavigationController {
//  
//  var scrollNavigationBar: ACScrollNavigationBar? {
//    get {
//      return self.navigationBar as? ACScrollNavigationBar
//    }
//  }
//}
