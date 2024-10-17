//
//  ScrollViewSharedVariables.swift
//  WodHopperPhone
//
//  Created by Michael Kloster on 07/03/24.
//  Copyright © 2024 Amagisoft LLC. All rights reserved.
//

import UIKit

class KeyboardAvoidingState: NSObject {
    var priorInset: UIEdgeInsets = .zero
    var priorScrollIndicatorInsets: UIEdgeInsets = .zero
    var keyboardVisible: Bool = false
    var keyboardRect: CGRect = .zero
    var priorContentSize: CGSize = .zero
    var priorPagingEnabled: Bool = false
    var ignoringNotifications: Bool = false
    var keyboardAnimationInProgress: Bool = false
    var animationDuration: CGFloat = 0.0
}

let kCalculatedContentPadding: CGFloat = 10
let kMinimumScrollOffsetPadding: CGFloat = 20
var kStateKey: UInt8 = 0
