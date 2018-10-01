//
//  AllExtensions.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/11/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    func setBottomLine(borderColor: UIColor) {
        
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        
        
        let borderLine = UIView()
        let height = 1.0
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - height,
                                  width: Double(self.frame.width),height: height)
        borderLine.layer.borderWidth = 2
        borderLine.layer.borderColor = UIColor.white.cgColor
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}


extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

extension UIViewController: UITextFieldDelegate {
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension Int64 {
    func timestampToDate() -> Date {
        let timeInterval = Double(self / 1000)
        return Date(timeIntervalSince1970: timeInterval)
    }
}


extension String {
    func toBool() -> Bool? {
        switch self  {
        case "True", "true":
            return true
        case "False", "false":
            return false
        default:
            return nil
        }
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension Array where Element == UIButton  {
    func hideButtons() {
        for btn in self {
            btn.isHidden = true
        }
    }
}

extension Encodable {
    var dictionary: [String: Any] {
        return (try? JSONSerialization
            .jsonObject(with: JSONEncoder().encode(self), options: []))
            as? [String: Any] ?? [:]
    }
}



































