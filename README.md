#ACScrollNavigationBar (swift)

> A scrollable UINavigationBar that follows a UIScrollView.

![](https://raw.githubusercontent.com/alexcorre/ACScrollNavigationBar/master/demo.gif)

## Overview

This project is very much in beta and experimental. It was originally based on [GTScrollNavigationBar](https://github.com/luugiathuy/GTScrollNavigationBar) and shared the same API.

Now, the API and implementation have changed drastically to make it easier to use in swift. Instead of having a subclass of UINavigationBar, we now are able to bring in scrollable nav functionality through two class extensions.
- `UINavigationBar+Scrollable.swift`
- `UIViewController+ScrollingNavBar.swift`

## Installation

### Manually
For now, until CocoaPods gets swift support, add the `ACScrollNavBar` project to your workspace. This project creates a Framework. Add this framework to your apps build phases under "Link Binary With Libraries"

Check out `ACScrollNavBar.xcworkspace` for an example.

## Usage

Setup the your UIViewController to implement the `NavigationScrollProvider` protocol. See example project for details.

```swift
extension SampleTableViewController: NavigationScrollProvider {

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

```

Note that you'll need to add some private instance properties to your view controller. This is required since the library is based on class extensions and thus cannot add stored properties to a class.

```swift
class MyTableViewController: UITableViewController {

    // MARK: - NavigationScrollProvider Stored Properties

    private var _panGesture: UIPanGestureRecognizer!
    private var _scrollState: String!
    private var _gestureIsActive = false
    private var _lastContentOffsetY: CGFloat = 0.0

}
```

Once your UIViewController is implementing the NavigationScrollProvider protocol, you can simple call `bindNavigationScrolling()` on `viewDidLoad()`. If you are not inside a `UINavigationController` or dont implement the `NavigationScrollProvider` protocol, this call will do nothing.

```swift

class MyTableViewController: UITableViewController {

  func viewDidLoad() {
    super.viewDidLoad()
    bindNavigationScrolling()
  }

}

```

If desired, implement `scrollViewDidScrollToTop(scrollView: UIScrollView!)` in your `UIScrollView's` delegate to reset the navigation bar.

```swift
func scrollViewDidScrollToTop(scrollView: UIScrollView) {
  resetNavBarPosition()
}

```

Thats it...

## Contact
- for questions please open an issue
- twitter: [@alexcorre](http://twitter.com/alexcorre)
