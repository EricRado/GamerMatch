//
//  RegistrationViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/6/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var reconfirmPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    let dbReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.usernameTextField.delegate = self
        self.reconfirmPasswordTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
    
    }
    
    /* override func viewDidLayoutSubviews() {
        emailTextField.setBottomLine(borderColor: UIColor.black)
        passwordTextField.setBottomLine(borderColor: UIColor.black)
        usernameTextField.setBottomLine(borderColor: UIColor.black)
    }*/
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func validateForm() {
        SVProgressHUD.show()
        if usernameTextField.text != nil {
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    print("There was an error: \(error!)")
                }else {
                    print("User registered successfully")
                    self.addUserToDatabase(uid: (user?.uid)!, email: self.emailTextField.text!, password: self.passwordTextField.text!, username: self.usernameTextField.text!)
                    self.performSegue(withIdentifier: "dashboardSegue", sender: self)
                }
            })
        }
    }
    
    func addUserToDatabase(uid: String, email: String, password: String, username: String){
        //let user = User(uid: uid, email: email, password: password, username: username)
        //dbReference.child("Users/\(uid)").setValue(user.toAnyObject())
        SVProgressHUD.dismiss()
    }
    
    
    @IBAction func returnBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "returnSegue", sender: self)
    }
    
    
    @IBAction func addPhotoBtnPressed(_ sender: UIButton) {
        print("Add photo btn pressed...")
    }
    
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        validateForm()
    }
    
}
