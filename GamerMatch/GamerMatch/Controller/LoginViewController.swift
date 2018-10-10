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
    
    private let registrationVCId = "RegistrationVC"
    var isInfoViewShowing = false
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
            self.emailTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
            self.passwordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var backgroundImg: UIImageView! {
        didSet {
            backgroundImg.alpha = 0.80
        }
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.layer.cornerRadius = 10
            signInButton.layer.masksToBounds = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        let lineColor = UIColor.black
        emailTextField.setBottomLine(borderColor: lineColor)
        passwordTextField.setBottomLine(borderColor: lineColor)
       
    }
    
    fileprivate func validateFields() -> Bool {
        if (emailTextField.text?.isEmpty)! {
            displayErrorMessage(with: "Email field is empty")
            return false
        }
        if (passwordTextField.text?.isEmpty)! {
            displayErrorMessage(with: "Password field is empty")
            return false
        }
        
        let predicate = EmailValidationPredicate()
        if !predicate.evaluate(with: emailTextField.text) {
            displayErrorMessage(with: "Email is not valid")
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
        guard validateFields() else { return }
        SVProgressHUD.show(withStatus: "Signing In")
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                self.displayErrorMessage(with: error.localizedDescription)
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
        guard let vc = storyboard?.instantiateViewController(withIdentifier: registrationVCId) as? RegistrationViewController else { return }
        let window = UIApplication.shared.windows[0] as UIWindow
        window.rootViewController = vc
    }

}
