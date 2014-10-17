//
//  UINavigationBar+Scrollable.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 10/17/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

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
