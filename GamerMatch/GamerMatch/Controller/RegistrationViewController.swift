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
import ValidationComponents

class RegistrationViewController: UIViewController {
    
    fileprivate let nextVCId = "ConsoleAndGameSelectionVC"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var reconfirmPasswordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    let userRef: DatabaseReference = {
        let ref = Database.database().reference().child("Users/")
        return ref
    }()
    
    lazy var userDict: [String: String] = {
        var dict = [String: String]()
        return dict
    }()
    
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
    
    fileprivate func validateForEmptyFields(updateUI: @escaping (UITextField?) -> Void) {
        if (usernameTextField.text?.isEmpty)! {
            updateUI(usernameTextField)
        }
        
        if (emailTextField.text?.isEmpty)! {
            updateUI(emailTextField)
        }
        
        if (passwordTextField.text?.isEmpty)! {
            updateUI(passwordTextField)
        }
        
        if (reconfirmPasswordTextField.text?.isEmpty)! {
            updateUI(reconfirmPasswordTextField)
        }
        
        updateUI(nil)
    }
    
    fileprivate func validateForm() {
        validateForEmptyFields { (textField) in
            if let textField = textField {
                textField.layer.borderColor = UIColor.red.cgColor
            }
        }
        
        if !(6 ... 16 ~= (usernameTextField.text?.count)!)  {
            print("username should be from 6 - 16 characters")
            return
        }
        
        if !(8 ... 18 ~= (passwordTextField.text?.count)!) {
            print("password should be from 8 - 18 characters")
            return
        }
        
        if passwordTextField.text != reconfirmPasswordTextField.text {
            print("passwords do not match")
            return
        }
        
        let predicate = EmailValidationPredicate()
        if !predicate.evaluate(with: emailTextField.text) {
            print("email is not valid")
            return
        }
        
        registerUser()
    }
    
    fileprivate func registerUser() {
        SVProgressHUD.show(withStatus: "Registering")
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { [unowned self] (user, error) in
            if error != nil {
                print("There was an error: \(error!)")
                return
            }
            print("User registered successfully")
            self.addUserToDatabase(uid: (user?.uid)!,
                                   email: self.emailTextField.text!,
                                   username: self.usernameTextField.text!)
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: self.nextVCId) else { return }
            self.present(vc, animated: true, completion: nil)
        })
    }
    
    
    fileprivate func addUserToDatabase(uid: String, email: String, username: String){
        let userDict = ["uid": uid, "email": email, "username": username,
                        "isOnline": "true", "url": "", "bio": ""]
        let ref = userRef.child("\(uid)")
        FirebaseCalls.shared.updateReferenceWithDictionary(ref: ref, values: userDict)
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
