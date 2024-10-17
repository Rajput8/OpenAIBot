import Foundation
import UIKit

class SharedMethods {
    
    static var shared = SharedMethods()
    
    func navigateToRootVC(rootVC: UIViewController) {
        // Ensure the key window scene is used
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let navigationController = UINavigationController(rootViewController: rootVC)
            navigationController.navigationBar.isHidden = true
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
    
    func pushTo(destVC: UIViewController, isAnimated: Bool = true) {
        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        DispatchQueue.main.async {
            topController.navigationController?.navigationBar.isHidden = true
            topController.navigationController?.pushViewController(destVC, animated: isAnimated)
        }
    }
    
    func presentVC(destVC: UIViewController, modalPresentationStyle: UIModalPresentationStyle = .popover) {
        guard let rootViewController = getWindowRootViewController() else { return }
        guard let topController = getTopViewController(from: rootViewController) else { return }
        DispatchQueue.main.async {
            destVC.modalPresentationStyle = modalPresentationStyle
            destVC.modalTransitionStyle = .coverVertical
            topController.present(destVC, animated: true)
        }
    }
    
    func getTopViewController(from rootViewController: UIViewController) -> UIViewController? {
        
        if let presentedViewController = rootViewController.presentedViewController {
            // If there's a presented view controller, it means we need to dig deeper
            return getTopViewController(from: presentedViewController)
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            // If the root view controller is a navigation controller, get the visible view controller
            return navigationController.visibleViewController
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            // If the root view controller is a tab bar controller, get the selected view controller
            if let selectedViewController = tabBarController.selectedViewController {
                return getTopViewController(from: selectedViewController)
            }
        }
        
        // If the root view controller is none of the above, return it
        return rootViewController
    }
    
    func getWindowRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return nil }
        return window.rootViewController
    }
}
