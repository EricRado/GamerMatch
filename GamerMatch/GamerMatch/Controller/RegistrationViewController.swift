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

    private let loginVCId = "LoginViewController"
    private var userImg: UIImage?
    private var isInfoViewShowing = false
    private var activeTextField: UITextField?
    
    @IBOutlet var inputFieldsContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.delegate = self
        }
    }
    @IBOutlet weak var reconfirmPasswordTextField: UITextField! {
        didSet {
            reconfirmPasswordTextField.delegate = self
        }
    }
    
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
    
    lazy var imageManager: ImageManager = {
        return ImageManager()
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(notification:)),
            name: Notification.Name.UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: Notification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .clear
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default
            .removeObserver(self,
                            name: Notification.Name.UIKeyboardWillShow,
                            object: nil)
        NotificationCenter.default
            .removeObserver(self,
                            name: Notification.Name.UIKeyboardWillHide,
                            object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc fileprivate func keyboardDidShow(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue)
            .cgRectValue
        let keyboardY = view.frame.size.height - keyboardSize.height - view.safeAreaInsets.bottom
        
        let editingTextFieldY: CGFloat! = (activeTextField?.frame.origin.y)! + inputFieldsContainerView.frame.origin.y
        
        // check if the textfield is really hidden behind the keyboard
        if view.frame.origin.y >= 0 && (editingTextFieldY > keyboardY - 60) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.frame = CGRect(
                    x: 0,
                    y: self.view.frame.origin.y - (editingTextFieldY! - (keyboardY - 60)),
                    width: self.view.bounds.width,
                    height: self.view.bounds.height)
            }, completion: nil)
        }
    }
    
    @objc fileprivate func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.frame.origin.y = 0
        }, completion: nil)
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
        guard let password = passwordTextField.text else { return }
        
        if username.hasWhiteSpace {
            displayErrorMessage(with: "Username cannot contain any spaces")
            return
        }
        
        if !(6 ... 16 ~= username.count)  {
            displayErrorMessage(with: "Username should be from 6 - 16 characters")
            return
        }
        
        if !(8 ... 18 ~= password.count) {
            displayErrorMessage(with: "Password should be from 8 - 18 characters")
            return
        }
        
        if password.hasWhiteSpace {
            displayErrorMessage(with: "Password cannot contain any spaces")
            return
        }
        
        if password != reconfirmPasswordTextField.text {
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
            guard let uid = user?.uid else { return }
            self.addUserToDatabase(uid: uid,
                                   email: self.emailTextField.text!,
                                   username: username)
            
            // upload image if user selected one
            if let image = self.userImg {
                self.uploadUserImg(uid: uid, image: image)
            }
            
            let gamerMatchCoreTabBarController = GamerMatchCoreTabBarController()
			self.show(gamerMatchCoreTabBarController, sender: nil)
        })
    }
    
    fileprivate func uploadUserImg(uid: String, image: UIImage){
        let path = "userProfileImages/\(uid).jpg"
        self.imageManager.uploadImage(image: image, at: path,
            completion: { (urlString, error) in
                if let error = error {
                    SVProgressHUD.dismiss()
                    self.displayErrorMessage(with: error.localizedDescription)
                    return
                }
                guard let url = urlString else { return }
                FirebaseCalls.shared.updateReferenceWithDictionary(
                    ref: self.userRef.child("\(uid)"),
                    values: ["url": url])
                FirebaseCalls.shared.updateReferenceWithDictionary(
                    ref: self.userCacheRef.child("\(uid)"),
                    values: ["url": url])
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
        guard let loginViewController = storyboard?.instantiateViewController(withIdentifier: loginVCId)
            as? LoginViewController else { return }
		loginViewController.modalPresentationStyle = .fullScreen
		show(loginViewController, sender: nil)
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
