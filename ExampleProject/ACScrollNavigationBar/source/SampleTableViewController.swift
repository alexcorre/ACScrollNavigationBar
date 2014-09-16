//
//  SampleTableViewController.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 6/27/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

class SampleTableViewController: UITableViewController {
  
  // MARK: View LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    setupNavigationBar()    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // attach the tableView to the scrollNavigationBar
    if let scrollNavBar = navigationController?.scrollNavigationBar {
      scrollNavBar.scrollView = tableView
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    // detatch the tableView from the scrollNavigationBar
    if let scrollNavBar = self.navigationController?.scrollNavigationBar {
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

  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
    var row = indexPath.row
    cell.textLabel?.text = String(row)

    return cell
  }
  
  // MARK: Navigation Bar Setup
  
  func setupNavigationBar() {
    navigationItem.title = "Demo TableViewController"
    
    // Color + Translucency
    var navColor = UIColor.colorFromHex(0x2576b1)
    navigationController?.navigationBar.barTintColor = navColor
    navigationController?.navigationBar.translucent = true
    
    // BarStyle affects Status Bar color + text color
    navigationController?.navigationBar.barStyle = .BlackTranslucent
  }
  
  // MARK: UIScrollViewDelegate
  
  override func scrollViewDidScrollToTop(scrollView: UIScrollView) {
    navigationController?.scrollNavigationBar?.resetToDefaultPosition(true)
  }
  
}
