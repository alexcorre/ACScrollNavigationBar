//
//  UIViewController+ScrollingNavbar.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 9/16/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

let kNearZero: CGFloat = 0.000001

enum NavigationScrollProviderScrollState: String {
    case None = "NONE"
    case ScrollingUp = "SCROLLING_UP"
    case ScrollingDown = "SCROLLING_DOWN"
}

@objc protocol NavigationScrollProvider {
    var panGesture: UIPanGestureRecognizer { get set }
    var scrollState: String { get set }
    var gestureIsActive: Bool { get set }
    var lastContentOffsetY: CGFloat { get set }
    
    func navigationScrollingView() -> UIScrollView
    func adjustScrollingViewInsets()
}

extension UINavigationBar {
    
    /**
    Resets this UINavigationBar to its natural position (not collapsed).
    
    :param: animated Whether or not to animate the change
    :param: scrollProvider A NavigationScrollProvider to be informed of the change
    */
    func scroll_nav_resetToDefaultPosition(animated: Bool, scrollProvider: NavigationScrollProvider) {
        var defaultFrame = frame
        defaultFrame.origin.y = scroll_nav_statusBarHeight()
        scroll_nav_setFrame(defaultFrame, alpha: 1.0, animated: animated, scrollProvider: scrollProvider)
    }
    
    /**
    Adjusts the frame of this UINavigation bar to the given frame, with a content alpha.
    
    :param: newFrame The frame to give this UINavigationBar
    :param: alpha The alpha of the content
    :param: animated Whether we should animate the frame / alpha change
    :param: scrollProvider The NavigationScrollProvider associated with this change being made. It will be adjusted accordingly.
    */
    func scroll_nav_setFrame(newFrame: CGRect, alpha: CGFloat, animated: Bool, scrollProvider: NavigationScrollProvider) {
        
        func moveFrame()  {
            var offsetY = CGRectGetMinY(newFrame) - CGRectGetMinY(self.frame)
            
            // set all subviews alphas to desired alpha...except background view which is (always?) first subview
            for subview in self.subviews as [UIView] {
                var isBackgroundView = (subview === self.subviews[0])
                var isViewHidden = subview.hidden || subview.alpha == 0.0
                
                if !(isBackgroundView || isViewHidden) {
                    subview.alpha = alpha
                }
            }
            
            // move the navbar
            self.frame = newFrame
            
            // adjust scrollview contentInset
            scrollProvider.adjustScrollingViewInsets()
        }
        
        // Animate the moveFrame() changes if desired, otherwise just execute them
        if animated {
            UIView.animateWithDuration(0.2, animations: moveFrame)
        } else {
            moveFrame()
        }
    }
    
    /**
    Convenience getter for the height of the status bar frame. On iOS 7 takes into account the
    user interface orientation. On iOS 8 this is not necessary.
    */
    func scroll_nav_statusBarHeight() -> CGFloat {
        let application = UIApplication.sharedApplication()
        let orientation = application.statusBarOrientation
        let statusBarFrame = application.statusBarFrame
        
        let versions = UIDevice.currentDevice().systemVersion.componentsSeparatedByString(".")
        if versions[0] == "7" {
            // ios 7 code
            switch orientation {
            case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
                return statusBarFrame.height
            case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
                return statusBarFrame.width
            default:
                return statusBarFrame.height
            }
        } else if versions[0] == "8" {
            // ios 8 code
            return statusBarFrame.height
        } else {
            return 20.0
        }
    }

    
}

extension UIViewController: UIGestureRecognizerDelegate {
    
    /**
    If this UIViewController instance implements the NavigationScrollProvider protocol, binds
    scrolling of the provided navigation scrolling view to the hiding / showing of the navigation
    bar.
    
    If this instance does not implement the NavigationScrollProvider protocol, or is not
    contained in a UINavigationController, this method is a noop.
    */
    func bindNavigationScrolling() {
        if let scrollProvider = self as? NavigationScrollProvider {
            if navigationController == nil {
                return
            }
            
            // here we know this UIViewController instance implements NavigationScrollProvider
            // and is contained in a UINavigationController
            var panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
            panGesture.delegate = self
            selfAsScrollProvider().panGesture = panGesture
            
            // bind to notifications
            bindNotifications()
            
            // clean the panGesture and add it to the newly set scrollView
            selfAsScrollProvider().navigationScrollingView().addGestureRecognizer(panGesture)
        } else {
            return
        }
    }
    
    // MARK: - Pan Gesture Handling
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        let scrollProvider = selfAsScrollProvider()
        let myScrollView = scrollProvider.navigationScrollingView()
        
        // return if the gesture is not attached to our scroll view
        if gesture.view !== myScrollView {
            return
        }
        
        if myScrollView.frame.size.height + (navigationController!.navigationBar.bounds.size.height * 2) >= myScrollView.contentSize.height {
            return
        }
        
        let contentOffsetY = myScrollView.contentOffset.y
        
        // Do nothing if we are scrolling the contentInset (padding)
        if contentOffsetY < -myScrollView.contentInset.top {
            return
        }
        
        // if the gesture just started...reset the state and store the last offset
        if gesture.state == .Began {
            scrollProvider.scrollState = NavigationScrollProviderScrollState.None.toRaw()
            scrollProvider.lastContentOffsetY = contentOffsetY
            scrollProvider.gestureIsActive = true
            return
        }
        
        var deltaY = contentOffsetY - scrollProvider.lastContentOffsetY
        if deltaY < 0.0 {
            scrollProvider.scrollState = NavigationScrollProviderScrollState.ScrollingDown.toRaw()
        } else if deltaY > 0.0 {
            scrollProvider.scrollState = NavigationScrollProviderScrollState.ScrollingUp.toRaw()
        }
        
        var newFrame = navigationController!.navigationBar.frame
        var alpha: CGFloat = 1.0
        var statusBarHeight = navigationController!.navigationBar.scroll_nav_statusBarHeight()
        var maxY = statusBarHeight
        var minY = maxY - CGRectGetHeight(newFrame) + 1.0
        
        let isScrolling = scrollProvider.scrollState == NavigationScrollProviderScrollState.ScrollingUp.toRaw() || scrollProvider.scrollState == NavigationScrollProviderScrollState.ScrollingDown.toRaw()
        scrollProvider.gestureIsActive = gesture.state != .Ended && gesture.state != .Cancelled
        
        if isScrolling && !scrollProvider.gestureIsActive {
            var contentOffsetYDelta: CGFloat = 0.0
            if scrollProvider.scrollState == NavigationScrollProviderScrollState.ScrollingDown.toRaw() {
                contentOffsetYDelta = maxY - newFrame.origin.y
                newFrame.origin.y = maxY
                alpha = 1.0
            }
            else if scrollProvider.scrollState == NavigationScrollProviderScrollState.ScrollingUp.toRaw() {
                contentOffsetYDelta = minY - newFrame.origin.y
                newFrame.origin.y = minY
                alpha = kNearZero
            }
            
            navigationController!.navigationBar.scroll_nav_setFrame(newFrame, alpha: alpha, animated: true, scrollProvider: scrollProvider)
            
            if !myScrollView.decelerating {
                var newContentOffset = CGPointMake(myScrollView.contentOffset.x, contentOffsetY - contentOffsetYDelta)
                myScrollView.setContentOffset(newContentOffset, animated: true)
            }
            
        } else {
            newFrame.origin.y -= deltaY;
            newFrame.origin.y = min(maxY, max(newFrame.origin.y, minY))
            
            alpha = (newFrame.origin.y - (minY + statusBarHeight)) / (maxY - (minY + statusBarHeight))
            alpha = max(kNearZero, alpha);
            
            navigationController!.navigationBar.scroll_nav_setFrame(newFrame, alpha: alpha, animated: false, scrollProvider: scrollProvider)
        }
        
        scrollProvider.lastContentOffsetY = contentOffsetY
    }
    
    // MARK: - NavigationScrollProvider
    
    func adjustScrollingViewInsets() {
        let scrollProvider = selfAsScrollProvider()
        var scrollView = scrollProvider.navigationScrollingView()
        
        if scrollView.contentInset.top == 0 && scrollView.contentOffset.y == 0 {
            return
        }
        
        var insets = scrollView.contentInset
        insets.top = navigationController!.navigationBar.frame.origin.y + navigationController!.navigationBar.frame.size.height
        scrollView.contentInset = insets
        println("setting insets.top \(insets.top)")
        
        let isAtTop = !scrollProvider.gestureIsActive && scrollView.contentOffset.y <= 0
        if isAtTop && scrollView.contentOffset.y != scrollView.contentInset.top {
            let newContentOffset = CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top)
            scrollView.setContentOffset(newContentOffset, animated: false)
            println("setting offset \(newContentOffset)")
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    // MARK: - Notifications
    
    private func bindNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarOrientationDidChange", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    private func unbindNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func statusBarOrientationDidChange() {
        selfAsScrollProvider().scrollState = NavigationScrollProviderScrollState.None.toRaw()
        navigationController!.navigationBar.scroll_nav_resetToDefaultPosition(false, scrollProvider: selfAsScrollProvider())
    }
    
    func applicationDidBecomeActive() {
        selfAsScrollProvider().scrollState = NavigationScrollProviderScrollState.None.toRaw()
        navigationController!.navigationBar.scroll_nav_resetToDefaultPosition(false, scrollProvider: selfAsScrollProvider())
    }
    
    // MARK: - Helpers
    
    /**
    Helper for getting self as a NavigationScrollProvider. This will crash if its called
    by a non-conformer. Should only be called from bindNavigationScrolling() which ensures
    this cast will succeed.
    */
    private func selfAsScrollProvider() -> NavigationScrollProvider {
        return self as NavigationScrollProvider
    }
    
}