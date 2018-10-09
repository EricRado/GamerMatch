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
    private let loginVCId = "LoginVC"
    fileprivate var userImg: UIImage?
    private var isInfoViewShowing = false
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var reconfirmPasswordTextField: UITextField!
    @IBOutlet weak var addPhotoBtn: UIButton! {
        didSet {
            addPhotoBtn.layer.cornerRadius = addPhotoBtn.frame.height / 2.0
            addPhotoBtn.clipsToBounds = true
            addPhotoBtn.addTarget(
                self,
                action: #selector(addPhotoBtnPressed(_:)),
                for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.layer.cornerRadius = 10
            signUpButton.layer.masksToBounds = true
        }
    }
    
    let userRef: DatabaseReference = {
        let ref = Database.database().reference().child("Users/")
        return ref
    }()
    
    let userCacheRef: DatabaseReference = {
        let ref = Database.database().reference().child("UserCacheInfo/")
        return ref
    }()
    
    lazy var userDict: [String: String] = {
        var dict = [String: String]()
        return dict
    }()
    
    lazy var imageManager: ImageManager = {
        return ImageManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.usernameTextField.delegate = self
        self.reconfirmPasswordTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view,
                                                              action: Selector("endEditing:")))
    
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
    
    fileprivate func validateForEmptyFields() -> Bool {
        if (usernameTextField.text?.isEmpty)! {
            displayErrorMessage(with: "Username field is empty")
            return false
        }
        
        if (emailTextField.text?.isEmpty)! {
            displayErrorMessage(with: "Email field is empty")
            return false
        }
        
        if (passwordTextField.text?.isEmpty)! {
            displayErrorMessage(with: "Password field is empty")
            return false
        }
        
        if (reconfirmPasswordTextField.text?.isEmpty)! {
            displayErrorMessage(with: "Confirm Password field is empty")
            return false
        }
        
        return true
    }
    
    fileprivate func validateForm() {
        guard validateForEmptyFields() else { return }
        guard let username = usernameTextField.text else { return }
        
        if !(6 ... 16 ~= username.count)  {
            displayErrorMessage(with: "Username should be from 6 - 16 characters")
            return
        }
        
        if !(8 ... 18 ~= (passwordTextField.text?.count)!) {
            displayErrorMessage(with: "Password should be from 8 - 18 characters")
            return
        }
        
        if passwordTextField.text != reconfirmPasswordTextField.text {
           displayErrorMessage(with: "Passwords do not match")
            return
        }
        
        let predicate = EmailValidationPredicate()
        if !predicate.evaluate(with: emailTextField.text) {
            displayErrorMessage(with: "Email is not valid")
            return
        }
        
        FirebaseCalls.shared.checkIfUsernameExists(username) { (check, error) in
            if let error = error {
                self.displayErrorMessage(with: error.localizedDescription)
                return
            }
            
            if check! {
                self.displayErrorMessage(with: "Username is already taken")
            } else {
                self.registerUser()
            }
        }
        
        
    }
    
    fileprivate func registerUser() {
        SVProgressHUD.show(withStatus: "Registering")
        Auth.auth().createUser(withEmail: emailTextField.text!,
                               password: passwordTextField.text!,
                               completion: { [unowned self] (user, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                self.displayErrorMessage(with: error.localizedDescription)
                return
            }
            print("User registered successfully")
            guard let username = self.usernameTextField.text else { return }
            self.addUserToDatabase(uid: (user?.uid)!,
                                   email: self.emailTextField.text!,
                                   username: username)
            
            // upload image if user selected one
            if let image = self.userImg {
                self.imageManager.uploadImage(image: image, at: "userProfileImages/\(username).jpg",
                                              completion: { (urlString, error) in
                    if let error = error {
                        SVProgressHUD.dismiss()
                        self.displayErrorMessage(with: error.localizedDescription)
                        return
                    }
                    guard let url = urlString else { return }
                    FirebaseCalls.shared.updateReferenceWithDictionary(
                        ref: self.userRef.child("\((user?.uid)!)"),
                        values: ["url": url])
                    FirebaseCalls.shared.updateReferenceWithDictionary(
                        ref: self.userCacheRef.child("\((user?.uid)!)"),
                        values: ["url": url])
                })
            }
            
            guard let vc = self.storyboard?
                .instantiateViewController(withIdentifier: self.nextVCId) else { return }
            self.present(vc, animated: true, completion: nil)
        })
    }
    
    
    fileprivate func addUserToDatabase(uid: String, email: String, username: String){
        let userDict = ["uid": uid, "email": email, "username": username,
                        "isOnline": "true", "url": "", "bio": ""]
        let userInfoDict = ["uid": uid,"url": "",
                            "username": username, "isOnline": "true"]
        
        let ref = userRef.child("\(uid)")
        FirebaseCalls.shared.updateReferenceWithDictionary(ref: ref, values: userDict)
        
        let cacheRef = userCacheRef.child("\(uid)")
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: cacheRef, values: userInfoDict)
        
        SVProgressHUD.dismiss()
    }
    
    
    @IBAction func returnBtnPressed(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: loginVCId)
            as? LoginViewController else { return }
        let window = UIApplication.shared.windows[0] as UIWindow
        window.rootViewController = vc
    }
    
    @objc func addPhotoBtnPressed(_ sender: UIButton) {
        CamaraHandler.shared.showActionSheet(vc: self)
        CamaraHandler.shared.imagePickedBlock = { [unowned self] image in
            self.addPhotoBtn.setImage(image, for: .normal)
            self.userImg = image
        }
    }
    
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        validateForm()
    }
    
}
