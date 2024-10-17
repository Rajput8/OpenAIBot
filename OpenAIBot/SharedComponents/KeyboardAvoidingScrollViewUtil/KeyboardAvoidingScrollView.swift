//
//  KeyboardAvoidingScrollViewUtil.swift
//  WodHopperPhone
//
//  Created by Michael Kloster on 06/03/24.
//  Copyright © 2024 Amagisoft LLC. All rights reserved.
//

import Foundation
import UIKit

class KeyboardAvoidingScrollView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerForKeyboardNotifications()
        // addTapGestureRecognizer()
        delaysContentTouches = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        registerForKeyboardNotifications()
        // addTapGestureRecognizer()
        delaysContentTouches = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let keyboardRect = self.convert(keyboardFrame, from: nil)
        if keyboardRect.isEmpty { return }
        let state = self.keyboardAvoidingState
        guard !state.ignoringNotifications else { return }
        state.animationDuration = animationDuration
        state.keyboardRect = keyboardRect
        if !state.keyboardVisible {
            state.priorInset = self.contentInset
            if #available(iOS 13.0, *) {
                state.priorScrollIndicatorInsets = UIEdgeInsets(top: self.verticalScrollIndicatorInsets.top,
                                                                left: self.horizontalScrollIndicatorInsets.left,
                                                                bottom: self.verticalScrollIndicatorInsets.bottom,
                                                                right: self.horizontalScrollIndicatorInsets.right)
            } else {
                state.priorScrollIndicatorInsets = self.scrollIndicatorInsets
            }
            
            state.priorPagingEnabled = self.isPagingEnabled
        }
        
        state.keyboardVisible = true
        self.isPagingEnabled = false
        let avoidingScrollView = KeyboardAvoidingScrollView()
        state.priorContentSize = self.contentSize
        if self.contentSize.equalTo(CGSize.zero) {
            self.contentSize = avoidingScrollView.calculatedContentSizeFromSubviewFrames()
        }
        
        // Delay until a future run loop such that the cursor position is available in a text view
        // In other words, it's not available (specifically, the prior cursor position is returned) when the first keyboard position change notification fires
        // NOTE: Unfortunately, using dispatch_async(main_queue) did not result in a sufficient-enough delay
        // for the text view's current cursor position to be available
        let delayTime = DispatchTime.now() + 0.01 // 0.01 seconds delay
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            // Accessing user info from the notification
            if let userInfo = notification.userInfo {
                // Your animation code here
                let animationCurveRawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
                let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue) ?? .easeInOut
                let animationOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
                let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.3
                UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
                    if let firstResponder = self.findFirstResponderBeneathView(self) {
                        self.contentInset = self.contentInsetForKeyboard()
                        let viewableHeight = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom
                        let idealOffset = self.idealOffsetForView(firstResponder, withViewingAreaHeight: viewableHeight)
                        self.setContentOffset(CGPoint(x: self.contentOffset.x, y: idealOffset), animated: false)
                    }
                    self.scrollIndicatorInsets = self.contentInset
                    self.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.contentInset = contentInsets
        self.scrollIndicatorInsets = contentInsets
    }
    
    func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}
