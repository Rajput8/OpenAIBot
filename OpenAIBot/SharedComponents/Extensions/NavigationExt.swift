import Foundation
import UIKit

extension UINavigationController {
    
    func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
    
    func popPushToVC(ofKind kind: AnyClass, pushController: UIViewController) {
        if containsViewController(ofKind: kind) {
            for controller in self.viewControllers {
                if controller.isKind(of: kind) {
                    guard let rootViewController = SharedMethods.shared.getWindowRootViewController()
                    else { return }
                    guard let topController = SharedMethods.shared.getTopViewController(from: rootViewController)
                    else { return }
                    DispatchQueue.main.async {
                        let transition = CATransition()
                        transition.duration = 0.5
                        transition.type = CATransitionType.fade
                        topController.view.window!.layer.add(transition, forKey: kCATransition)
                        self.popToViewController(controller, animated: false)
                    }
                    break
                }
            }
        } else {
            guard let rootViewController = SharedMethods.shared.getWindowRootViewController()
            else { return }
            guard let topController = SharedMethods.shared.getTopViewController(from: rootViewController)
            else { return }
            DispatchQueue.main.async {
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = CATransitionType.fade
                topController.view.window!.layer.add(transition, forKey: kCATransition)
                self.pushViewController(pushController, animated: false)
            }
        }
    }
}
