//
//  LoginViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/6/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ValidationComponents


class LoginViewController: UIViewController {
    
    var isInfoViewShowing = false
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        }
    }
    
    @IBOutlet weak var backgroundImg: UIImageView! {
        didSet {
            backgroundImg.alpha = 0.80
        }
    }
    
    @IBOutlet weak var signInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alpha = 0.75

        // Do any additional setup after loading the view.
        signInButton.layer.cornerRadius = 10
        signInButton.layer.masksToBounds = true
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.95)
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        
    }
    
    override func viewDidLayoutSubviews() {
        let lineColor = UIColor.black
        emailTextField.setBottomLine(borderColor: lineColor)
        passwordTextField.setBottomLine(borderColor: lineColor)
       
    }
    
    fileprivate func validateFields() -> Bool {
        let completion: (Bool) -> Void = { isFinished in
            if isFinished {
                self.isInfoViewShowing = false
            }
        }
        
        if (emailTextField.text?.isEmpty)! {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Email field is empty", type: .Error,
                                completion: completion)
            }
            return false
        }
        if (passwordTextField.text?.isEmpty)! {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Password field is empty", type: .Error,
                                completion: completion)
            }
            return false
        }
        
        let predicate = EmailValidationPredicate()
        if !predicate.evaluate(with: emailTextField.text) {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Email is not valid", type: .Error,
                                completion: completion)
            }
            return false
        }
        
        /*if !(8 ... 18 ~= (passwordTextField.text?.count)!) {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Password should be from 8 - 18 characters",
                                type: .Error, completion: completion)
            }
            return false
        }*/
        
        return true
    }

    
    @IBAction func signInPressed(_ sender: UIButton) {
        let completion: (Bool) -> Void = { isFinished in
            if isFinished {
                self.isInfoViewShowing = false
            }
        }
        guard validateFields() else { return }
        SVProgressHUD.show(withStatus: "Signing In")
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                if !self.isInfoViewShowing {
                    self.isInfoViewShowing = true
                    self.displayInfoView(message: error.localizedDescription, type: .Error,
                                         completion: completion)
                }
                
            } else {
                print("Login successful")
                // setup all of the signed in user info to User singleton object
                User.onlineUser.retrieveUserInfo(uid: (user?.uid)!)
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "signinDashboardSegue", sender: self)
            }
        }
    }
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "registrationSegue", sender: self)
    }

}
