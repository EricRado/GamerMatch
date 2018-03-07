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
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var formIsValid: Bool = false
    
    let dbReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
    
    }
    
     override func viewDidLayoutSubviews() {
        emailTextField.setBottomLine(borderColor: UIColor.black)
        passwordTextField.setBottomLine(borderColor: UIColor.black)
        usernameTextField.setBottomLine(borderColor: UIColor.black)
    }
    
    func validateForm() -> Bool{
        var formIsValid = false
        if usernameTextField.text != nil {
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    print("There was an error: \(error!)")
                }else {
                    print("User registered successfully")
                    self.addUserToDatabase(uid: (user?.uid)!, email: self.emailTextField.text!, password: self.passwordTextField.text!, username: self.usernameTextField.text!)
                }
            })
            formIsValid = true
        }
        print("This is formIsValid value:  \(formIsValid)")
        return formIsValid
    }
    
    func addUserToDatabase(uid: String, email: String, password: String, username: String){
        let user = User(uid: uid, email: email, password: password, username: username)
        dbReference.child("Users/\(uid)").setValue(user.toAnyObject())
        SVProgressHUD.dismiss()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "dashboardSegue"{
            if validateForm(){
                print("Form is valid")
                return true
            }else {
                print("Form is invalid")
            }
        }
        return false
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
