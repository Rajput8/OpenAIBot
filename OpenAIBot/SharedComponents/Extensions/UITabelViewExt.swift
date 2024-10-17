import UIKit

extension UITableView {
    
    func registerCellFromNib(cellID: String) {
        self.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    func setEmptyMessage(_ message: String, animationName: String) {
        // Remove any existing background view
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
