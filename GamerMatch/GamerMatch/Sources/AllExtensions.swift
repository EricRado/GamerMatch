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

enum MessageType {
    case Error
    case Success
}

extension UIViewController {
    
    func displayErrorMessage(with message: String) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate
            else { return}
        
        let completion: (Bool) -> Void = { [unowned delegate] isFinished in
            if isFinished {
                delegate.isInfoViewShowing = false
            }
        }
        
        if !delegate.isInfoViewShowing {
            delegate.isInfoViewShowing = true
            displayInfoView(message: message,
                            type: .Error,
                            completion: completion)
        }
    }
    
    func displaySuccessfulMessage(with message: String) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate
            else { return}
        
        let completion: (Bool) -> Void = { [unowned delegate] isFinished in
            if isFinished {
                delegate.isInfoViewShowing = false
            }
        }
        
        if !delegate.isInfoViewShowing {
            delegate.isInfoViewShowing = true
            displayInfoView(message: message,
                            type: .Success,
                            completion: completion)
        }
    }
    
    
    fileprivate func displayInfoView(message: String, type: MessageType,
                         completion: ((Bool) -> Void)?) {
        let infoViewHeight = view.bounds.height / 14.2
        let infoViewY = 0 - infoViewHeight
        var bgColor: UIColor
        
        // set view background color
        switch type {
        case .Error:
            bgColor = UIColor(red: 1, green: 50/255, blue: 75/255, alpha: 1)
        case .Success:
            bgColor = UIColor(red: 30/255, green: 244/255, blue: 125/255, alpha: 1)
        }
        
        let infoView = UIView(frame: CGRect(x: 0, y: infoViewY, width: view.bounds.width, height: infoViewHeight))
        infoView.backgroundColor = bgColor
        view.addSubview(infoView)
        
        // info label to show text
        let infoLabelWidth = infoView.bounds.width
        let infoLabelHeight = infoView.bounds.height + UIApplication.shared.statusBarFrame.height / 2
        
        let infoLabel = UILabel()
        infoLabel.frame.size.width = infoLabelWidth
        infoLabel.frame.size.height = infoLabelHeight
        infoLabel.numberOfLines = 0
        
        infoLabel.text = message
        infoLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        
        infoView.addSubview(infoLabel)
        
        // animate info view
        
        UIView.animate(withDuration: 0.2, animations: {
            infoView.frame.origin.y = 0
        }) { (finished) in
            if finished {
                UIView.animate(withDuration: 0.1, delay: 3, options: .curveLinear
                    , animations: {
                        infoView.frame.origin.y = infoViewY
                }, completion: { (finished) in
                    if finished {
                        infoView.removeFromSuperview()
                        infoLabel.removeFromSuperview()
                        completion?(finished)
                    }
                })
            }
        }
    }
}

































