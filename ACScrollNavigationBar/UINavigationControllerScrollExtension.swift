//
//  UINavigationControllerScrollExtension.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 6/28/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

extension UINavigationController {
  
  /// Computed property with getter to access the ACScrollNavigationBar if it exists. If
  /// navigationBar property is nil or not an instance of ACScrollNavigationBar, this property
  /// will be nil.
  var scrollNavigationBar: ACScrollNavigationBar? {
    get {
        return navigationBar as? ACScrollNavigationBar
    }
  }
}
