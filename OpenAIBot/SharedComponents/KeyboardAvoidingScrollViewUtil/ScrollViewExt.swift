//
//  ScrollViewExt.swift
//  WodHopperPhone
//
//  Created by Michael Kloster on 07/03/24.
//  Copyright © 2024 Amagisoft LLC. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var keyboardAvoidingState: KeyboardAvoidingState {
        get {
            if let state = objc_getAssociatedObject(self, &kStateKey) as? KeyboardAvoidingState {
                return state
            } else {
                let state = KeyboardAvoidingState()
                objc_setAssociatedObject(self, &kStateKey, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return state
            }
        }
    }
    
    func findFirstResponderBeneathView(_ view: UIView) -> UIView? {
        // Search recursively for first responder
        for childView in view.subviews {
            if childView.responds(to: #selector(getter: UIResponder.isFirstResponder)) && childView.isFirstResponder {
                return childView
            }
            if let result = findFirstResponderBeneathView(childView) {
                return result
            }
        }
        return nil
    }
    
    func contentInsetForKeyboard() -> UIEdgeInsets {
        let state = keyboardAvoidingState
        var newInset = contentInset
        let keyboardRect = state.keyboardRect
        let prefs = UserDefaults.standard
        if let controllerName = prefs.string(forKey: "controllerName"), controllerName == "FilterPopup" {
            newInset.bottom = 600.0
        } else {
            newInset.bottom = keyboardRect.size.height - max(keyboardRect.maxY - bounds.maxY, 0)
        }
        return newInset
    }
    
    func calculatedContentSizeFromSubviewFrames() -> CGSize {
        let wasShowingVerticalScrollIndicator = self.showsVerticalScrollIndicator
        let wasShowingHorizontalScrollIndicator = self.showsHorizontalScrollIndicator
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        var rect = CGRect.zero
        for view in self.subviews {
            rect = rect.union(view.frame)
        }
        rect.size.height += kCalculatedContentPadding
        self.showsVerticalScrollIndicator = wasShowingVerticalScrollIndicator
        self.showsHorizontalScrollIndicator = wasShowingHorizontalScrollIndicator
        return rect.size
    }
    
    func idealOffsetForView(_ view: UIView, withViewingAreaHeight viewAreaHeight: CGFloat) -> CGFloat {
        let contentSize = self.contentSize
        var offset: CGFloat = 0.0
        let subviewRect = view.convert(view.bounds, to: self)
        var padding: CGFloat = 0.0
        var contentInset: UIEdgeInsets
        
        if #available(iOS 11.0, *) {
            contentInset = adjustedContentInset
        } else {
            contentInset = self.contentInset
        }
        
        let centerViewInViewableArea: () -> Void = {
            // Attempt to center the subview in the visible space
            padding = (viewAreaHeight - subviewRect.size.height) / 2
            
            // But if that means there will be less than kMinimumScrollOffsetPadding
            // pixels above the view, then substitute kMinimumScrollOffsetPadding
            if padding < kMinimumScrollOffsetPadding {
                padding = kMinimumScrollOffsetPadding
            }
            
            // Ideal offset places the subview rectangle origin "padding" points from the top of the scrollview.
            // If there is a top contentInset, also compensate for this so that subviewRect will not be placed under
            // things like navigation bars.
            offset = subviewRect.origin.y - padding - contentInset.top
        }
        
        centerViewInViewableArea()
        
        // Constrain the new contentOffset so we can't scroll past the bottom. Note that we don't take the bottom
        // inset into account, as this is manipulated to make space for the keyboard.
        let maxOffset = contentSize.height - viewAreaHeight - contentInset.top
        if offset > maxOffset { offset = maxOffset }
        
        // Constrain the new contentOffset so we can't scroll past the top, taking contentInsets into account
        if offset < -contentInset.top { offset = -contentInset.top }
        
        return offset
    }
}
