#ACScrollNavigationBar (swift)

A scrollable UINavigationBar that follows a UIScrollView. This project is a port of [GTScrollNavigationBar](https://github.com/luugiathuy/GTScrollNavigationBar) to swift for iOS 7+.

##Installation
###CocoaPods
Coming soon.

###Manually
Add the `ACScrollNavigationBar` folder to your project.

##Usage

Setup the NavigationController to use ACScrollNavigationBar

```swift
var navController = UINavigationController(navigationBarClass: ACScrollNavigationBar.self, toolbarClass: nil)

var vc = SampleTableViewController(style: UITableViewStyle.Plain)
navController.setViewControllers([vc], animated: false)
```

In your ViewController that has a scrollview (self.tableView in the example), attach the scroll view to the ACScrollNavigationBar on `viewWillAppear(animated: Bool)` and detatch it on `viewWillDisappear(animated: Bool)`

```swift

// viewWillAppear()

if let scrollNavBar = self.navigationController.scrollNavigationBar {
  scrollNavBar.scrollView = self.tableView
}

// viewWillDissapear()

if let scrollNavBar = self.navigationController.scrollNavigationBar {
  scrollNavBar.scrollView = nil
}

```

##Contact
[@alexcorre](http://twitter.com/alexcorre)
