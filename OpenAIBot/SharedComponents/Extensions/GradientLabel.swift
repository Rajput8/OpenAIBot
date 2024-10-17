import UIKit

@IBDesignable
class PatternedLabel: UILabel {
    
    @IBInspectable var patternImage: UIImage? {
        didSet {
            updateTextColor()
        }
    }
    
    private func updateTextColor() {
        guard let img = patternImage else {
            return
        }
        self.textColor = UIColor(patternImage: img)
    }
}
