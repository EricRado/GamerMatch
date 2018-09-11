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

class LoginViewController: UIViewController {
    
    
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

    
    @IBAction func signInPressed(_ sender: UIButton) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print("There was an error : \((error?.localizedDescription)!)")
                SVProgressHUD.dismiss()
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
