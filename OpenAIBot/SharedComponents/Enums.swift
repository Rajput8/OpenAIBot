import UIKit

enum AppStoryboards: String {
    case main = "Main"
    case tabbars = "Home"
    
    var storyboardInstance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    func getController(identifier: String) -> UIViewController? {
        return storyboardInstance.instantiateViewController(withIdentifier: identifier)
    }
}
