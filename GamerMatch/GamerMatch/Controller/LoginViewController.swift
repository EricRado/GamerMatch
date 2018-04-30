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

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signInButton.layer.cornerRadius = 10
        signInButton.layer.masksToBounds = true
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.95)
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
            }else {
                print("Login successful")
                User.onlineUser.retrieveUserInfo(uid: (user?.uid)!)
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "signinDashboardSegue", sender: self)
            }
        }
    }
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "registrationSegue", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
