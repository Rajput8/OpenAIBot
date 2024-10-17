import UIKit

@IBDesignable
class CustomView: UIView {}


extension UIView {
    
    private struct AssociatedKey {
        static var rounded = "UIView.rounded"
    }
    
    @IBInspectable var rounded: Bool {
        get {
            if let rounded = objc_getAssociatedObject(self, &AssociatedKey.rounded) as? Bool {
                return rounded
            } else {
                return false
            }
        }
        set {
            DispatchQueue.main.async {
                objc_setAssociatedObject(self, &AssociatedKey.rounded, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.layer.cornerRadius = CGFloat(newValue ? 1.0 : 0.0)*min(self.bounds.width,
                                                                            self.bounds.height)/2
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get { return UIColor.init(cgColor: layer.shadowColor!) }
        set { layer.shadowColor = newValue.cgColor }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    
    @IBInspectable var maskToBounds: Bool {
        get { return layer.masksToBounds }
        set { layer.masksToBounds = newValue }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable var cornerradius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { return layer.cornerRadius }
    }
    
    func setViewCircle() {
        self.layer.cornerRadius = self.bounds.size.height / 2.0
        self.clipsToBounds = true
    }
    
    // MARK: Method for getting uiview's components
    func viewOfType<T: UIView>(type: T.Type, process: (_ view: T) -> Void) {
        if let view = self as? T {
            process(view)
        } else {
            for subView in subviews { subView.viewOfType(type: type, process: process) }
        }
    }
    
    func allButtons() -> [UIButton] {
        var buttons = [UIButton]()
        
        // Check if the current view is a UIButton
        if let button = self as? UIButton {
            buttons.append(button)
        }
        
        // Recursively check subviews
        for subview in self.subviews {
            buttons.append(contentsOf: subview.allButtons())
        }
        
        return buttons
    }
    
    func allImageViews() -> [UIImageView] {
        var imageViews = [UIImageView]()
        
        // Check if the current view is a UIImageView
        if let imageView = self as? UIImageView {
            imageViews.append(imageView)
        }
        
        // Recursively check subviews
        for subview in self.subviews {
            imageViews.append(contentsOf: subview.allImageViews())
        }
        
        return imageViews
    }
}
