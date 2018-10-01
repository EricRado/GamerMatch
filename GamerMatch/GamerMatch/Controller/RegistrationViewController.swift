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
    fileprivate var userImg: UIImage?
    var isInfoViewShowing = false
    
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
    
    @IBOutlet weak var signUpButton: UIButton!
    
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
    
    fileprivate func validateForEmptyFields() -> Bool {
        let completion: (Bool) -> Void = { isFinished in
            if isFinished {
                self.isInfoViewShowing = false
            }
        }
        
        if (usernameTextField.text?.isEmpty)! {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Username field is empty", type: .Error,
                                completion: completion)
            }
            return false
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
        
        if (reconfirmPasswordTextField.text?.isEmpty)! {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Confirm Password field is empty", type: .Error,
                                completion: completion)
            }
            return false
        }
        
    
        return true
    }
    
    fileprivate func validateForm() {
        guard validateForEmptyFields() else { return }
        
        let completion: (Bool) -> Void = { isFinished in
            if isFinished {
                self.isInfoViewShowing = false
            }
        }
        
        if !(6 ... 16 ~= (usernameTextField.text?.count)!)  {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Username should be from 6 - 16 characters", type: .Error, completion: completion)
            }
            return
        }
        
        if !(8 ... 18 ~= (passwordTextField.text?.count)!) {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "password should be from 8 - 18 characters", type: .Error, completion: completion)
            }
            return
        }
        
        if passwordTextField.text != reconfirmPasswordTextField.text {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Passwords do not match", type: .Error,
                                completion: completion)
            }
            return
        }
        
        let predicate = EmailValidationPredicate()
        if !predicate.evaluate(with: emailTextField.text) {
            if !isInfoViewShowing {
                isInfoViewShowing = true
                displayInfoView(message: "Email is not valid", type: .Error,
                                completion: completion)
            }
            return
        }
        
        registerUser()
    }
    
    fileprivate func registerUser() {
        let completion: (Bool) -> Void = { isFinished in
            if isFinished {
                self.isInfoViewShowing = false
            }
        }
        
        SVProgressHUD.show(withStatus: "Registering")
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { [unowned self] (user, error) in
            if let error = error {
                if !self.isInfoViewShowing {
                    self.isInfoViewShowing = true
                    self.displayInfoView(message: error.localizedDescription, type: .Error,
                                    completion: completion)
                }
                return
            }
            print("User registered successfully")
            guard let username = self.usernameTextField.text else { return }
            self.addUserToDatabase(uid: (user?.uid)!,
                                   email: self.emailTextField.text!,
                                   username: username)
            
            // upload image if user selected one
            if let image = self.userImg {
                self.imageManager.uploadImage(image: image, at: "userProfileImages/\(username).jpg", completion: { (urlString, error) in
                    if let error = error {
                        self.displayInfoView(message: error.localizedDescription, type: .Error, completion: { (finished) in
                            if finished {
                                self.isInfoViewShowing = false
                            }
                        })
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
        performSegue(withIdentifier: "returnSegue", sender: self)
    }
    
    @objc func addPhotoBtnPressed(_ sender: UIButton) {
        print("Add photo btn pressed...")
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
