//
//  LoginViewController.swift
//  Project1
//
//  Created by Laptop on 28.04.2022.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func changeViewController(){
        let homeNavigationController = storyboard?.instantiateViewController(identifier: "homeNavigationController") as? UINavigationController
        view.window?.rootViewController = homeNavigationController
        view.window?.makeKeyAndVisible()
    }
    
    func loginUser(){
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil{
                print(error!.localizedDescription)
                self.errorMessageLabel.text = "Could not log in. Please try again"
                return
            }else {
                self.changeViewController()
            }
        }
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        if (emailTextField.text!.isEmpty) || (passwordTextField.text!.isEmpty) {
            errorMessageLabel.text = "Please fill in all the labels"
        }else {
            errorMessageLabel.text = ""
            loginUser()
        }
    }
}
