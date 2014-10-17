//
//  SampleTableViewController.swift
//  ACScrollNavigationBarExample
//
//  Created by Alex Corre on 9/17/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit

class SampleTableViewController: UITableViewController {
    
    // MARK: - NavigationScrollProvider Stored Properties

    private var _panGesture: UIPanGestureRecognizer!
    private var _scrollState: String!
    private var _gestureIsActive = false
    private var _lastContentOffsetY: CGFloat = 0.0


    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupNavigationBar()
        bindNavigationScrolling()
    }
    
    // MARK: - UITableViewDataSource
    
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
    
    // MARK: - NavBar Setup

    func setupNavigationBar() {
        navigationItem.title = "Demo TableViewController"
        var navColor = UIColor.colorFromHex(0x2576b1)
        navigationController?.navigationBar.barTintColor = navColor
        navigationController?.navigationBar.barStyle = .BlackTranslucent
    }


}

// MARK: - NavigationScorllProvider

extension SampleTableViewController: NavigationScrollProvider {

    var panGesture: UIPanGestureRecognizer {
        get {
            return _panGesture
        }
        set {
            _panGesture = newValue
        }
    }

    var scrollState: String {
        get {
            return _scrollState
        }
        set {
            _scrollState = newValue
        }
    }

    var gestureIsActive: Bool {
        get {
            return _gestureIsActive
        }
        set {
            _gestureIsActive = newValue
        }
    }

    var lastContentOffsetY: CGFloat {
        get {
            return _lastContentOffsetY
        }
        set {
            _lastContentOffsetY = newValue
        }
    }

    func navigationScrollingView() -> UIScrollView {
        return tableView
    }

}
