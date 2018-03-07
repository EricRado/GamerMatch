//
//  LoginViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/6/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

extension UITextField{
    func setBottomLine(borderColor: UIColor) {
        
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        
        let borderLine = UIView()
        let height = 1.0
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - height,
                                  width: Double(self.frame.width),height: height)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signInButton.layer.cornerRadius = 10
        signInButton.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        let lineColor = UIColor.black
        emailTextField.setBottomLine(borderColor: lineColor)
        passwordTextField.setBottomLine(borderColor: lineColor)
       
    }

    
    @IBAction func signInPressed(_ sender: UIButton) {
        
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