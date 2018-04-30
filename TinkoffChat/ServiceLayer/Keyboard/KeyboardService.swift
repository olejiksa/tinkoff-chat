//
//  KeyboardService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation
import UIKit

protocol IKeyboardModel {
    func setKeyboardDelegate(_ delegate: UIView?)
    func turnKeyboard(on: Bool)
}

protocol IKeyboardService {
    var delegate: UIView? { get set }
    
    func turnKeyboard(on: Bool)
    
    func keyboardWillHide(notification: Notification)
    func keyboardWillAppear(notification: Notification)
    func inputModeDidChange(notification: Notification)
    
    func dismissKeyboard()
}

class KeyboardService: IKeyboardService {
    
    weak var delegate: UIView?
    
    func turnKeyboard(on: Bool) {
        if on {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name:
                .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:
                .UIKeyboardWillHide, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange), name:
                .UIKeyboardWillChangeFrame, object: nil)
            
            delegate?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        } else {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
            
            delegate?.gestureRecognizers?.removeAll()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let y = delegate?.frame.origin.y else { return }
        
        if y >= 0 {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            delegate?.frame.origin.y += keyboardSize.height
        }
    }
    
    @objc func keyboardWillAppear(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            delegate?.frame.origin.y -= keyboardSize.height
        }
    }
    
    @objc func inputModeDidChange(notification: Notification) {
        delegate?.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard() {
        delegate?.endEditing(true)
        delegate?.frame.origin.y = 0
    }
    
}
