//
//  SampleTableViewController.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 6/27/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

extension UINavigationController {
  
  var scrollNavigationBar: ACScrollNavigationBar? {
    get {
      return self.navigationBar as? ACScrollNavigationBar
    }
  }
}

extension UIColor {
  
  class func colorFromHex(hexValue: UInt) -> UIColor {
    return UIColor(
      red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(hexValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }

}

class SampleTableViewController: UITableViewController {
  
  // #pragma mark - View LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    setupNavigationBar()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let scrollNavBar = self.navigationController.scrollNavigationBar {
      scrollNavBar.scrollView = self.tableView
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    if let scrollNavBar = self.navigationController.scrollNavigationBar {
      scrollNavBar.scrollView = nil
    }
  }

  // #pragma mark - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return 100
  }

  
  override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
    // is this ok to unwrap like this?
    let cell = tableView!.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
    var row = indexPath?.row
    cell.text = String(row!)

    return cell
  }
  
  // MARK: Navigation Bar Setup
  
  func setupNavigationBar() {
    self.navigationItem.title = "Demo TableViewController"
    
    // Color + Translucency
    var navColor = UIColor.colorFromHex(0x2576b1)
    self.navigationController.navigationBar.barTintColor = navColor
    self.navigationController.navigationBar.translucent = true
    
    // BarStyle affects Status Bar color + text color
    self.navigationController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
  }
  
}
