import Foundation
import UIKit

extension UILabel {
    
    func formatting() {
        textAlignment = .left
        textColor = .label
        font = .systemFont(ofSize: 14.0, weight: .medium)
        numberOfLines = 0
        lineBreakMode = .byCharWrapping
        // sizeToFit()
    }
}
