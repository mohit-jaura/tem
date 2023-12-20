import UIKit

protocol ViewableControllerContainer {}

protocol ViewableControllerContainerDataSource: AnyObject {
    func numberOfPagesInViewableControllerContainer(_ viewableControllerContainer: ViewableControllerContainer) -> Int
    func viewableControllerContainer(_ viewableControllerContainer: ViewableControllerContainer, controllerAtIndex index: Int) -> UIViewController
}

protocol ViewableControllerContainerDelegate: AnyObject {
    func viewableControllerContainer(_ viewableControllerContainer: ViewableControllerContainer, didMoveToIndex index: Int)
    func viewableControllerContainer(_ viewableControllerContainer: ViewableControllerContainer, didMoveFromIndex index: Int)
}

