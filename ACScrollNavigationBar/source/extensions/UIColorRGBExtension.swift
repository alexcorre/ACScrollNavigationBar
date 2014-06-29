//
//  UIColorRGBExtension.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 6/28/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

extension UIColor {
  
  /*! Creates UIColor instance from a hex color value.
   *
   * Example:
   * let someColor = UIColor.colorFromHex(0xaabbcc)
   */
  class func colorFromHex(hexValue: UInt) -> UIColor {
    return UIColor(
      red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(hexValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
  
}

