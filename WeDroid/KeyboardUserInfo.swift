//
//  KeyboardUserInfo.swift
//  WeDroid
//
//  Created by v on 2021/5/20.
//

import UIKit

struct KeyboardUserInfo {
    var animationDuration: TimeInterval = 0
    var frameBegin: CGRect = .zero
    var frameEnd: CGRect = .zero
    var animationCurve: UIView.AnimationCurve = .easeInOut
    var isLocal: Bool = true

    init(userInfo: [AnyHashable: Any]) {
        if let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            self.animationDuration = animationDuration
        }

        if let animationCurveRawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int {
            self.animationCurve = UIView.AnimationCurve(rawValue: animationCurveRawValue)!
        }

        if let frameBegin = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
            self.frameBegin = frameBegin
        }

        if let frameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            self.frameEnd = frameEnd
        }

        if let isLocal = userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? Bool {
            self.isLocal = isLocal
        }
    }

    func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration, animations: animations, completion: completion)
    }
}
