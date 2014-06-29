//
//  SampleTableViewController.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 6/27/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

// Due to a swift compiler bug...extenstions with computed properties must be decalred
// in the same file that they are used.
// TODO move this into its own file
extension UINavigationController {
  
  var scrollNavigationBar: ACScrollNavigationBar? {
    get {
      return self.navigationBar as? ACScrollNavigationBar
    }
  }
}

class SampleTableViewController: UITableViewController {
  
  // MARK: View LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    setupNavigationBar()    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // attach the tableView to the scrollNavigationBar
    if let scrollNavBar = self.navigationController.scrollNavigationBar {
      scrollNavBar.scrollView = self.tableView
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    // detatch the tableView from the scrollNavigationBar
    if let scrollNavBar = self.navigationController.scrollNavigationBar {
      scrollNavBar.scrollView = nil
    }
  }

  // MARK: UITableViewDataSource

  override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return 100
  }

  
  override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
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
  
  // MARK: UIScrollViewDelegate
  
  override func scrollViewDidScrollToTop(scrollView: UIScrollView!) {
    self.navigationController.scrollNavigationBar?.resetToDefaultPosition(true)
  }
  
}
