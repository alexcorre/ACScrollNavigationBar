//
//  ViewController.swift
//  DemoApp
//
//  Created by Alex Corre on 10/17/14.
//  Copyright (c) 2014 Alex Corre. All rights reserved.
//

import UIKit
import ACScrollNavBar

class RootViewController: UITableViewController {

    // MARK: - NavigationScrollProvider Stored Properties

    private var _panGesture: UIPanGestureRecognizer!
    private var _scrollState: String!
    private var _gestureIsActive = false
    private var _lastContentOffsetY: CGFloat = 0.0

    // MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        bindNavigationScrolling()
    }


    // MARK: - Setup

    func registerCells() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

}

// MARK: - UITableViewDataSource

extension RootViewController {

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

}

// MARK: - UIScrollViewDelegate

extension RootViewController {

    override func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        resetNavBarPosition()
    }

}

// MARK: - NavigationScrollProvider

extension RootViewController: NavigationScrollProvider {

    var panGesture: UIPanGestureRecognizer {
        get { return _panGesture }
        set { _panGesture = newValue }
    }

    var scrollState: String {
        get { return _scrollState }
        set { _scrollState = newValue }
    }

    var gestureIsActive: Bool {
        get { return _gestureIsActive }
        set { _gestureIsActive = newValue }
    }

    var lastContentOffsetY: CGFloat {
        get { return _lastContentOffsetY }
        set { _lastContentOffsetY = newValue }
    }

    func navigationScrollingView() -> UIScrollView {
        return tableView
    }

}

