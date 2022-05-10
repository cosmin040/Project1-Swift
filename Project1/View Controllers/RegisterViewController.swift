//
//  RegisterViewController.swift
//  Project1
//
//  Created by Laptop on 28.04.2022.
//

import UIKit
import FirebaseAuth
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func checkFields() -> String? {
        if firstNameTextField.text!.isEmpty ||
            lastNameTextField.text!.isEmpty ||
            emailTextField.text!.isEmpty ||
            passwordTextField.text!.isEmpty
        {
            return "Please fill in all the labels"
        }
        else if firstNameTextField.text!.contains(" ") ||
                    lastNameTextField.text!.contains(" ") ||
                    emailTextField.text!.contains(" ") ||
                    passwordTextField.text!.contains(" ")
        {
            return "Please remove spaces"
        }
        return nil
    }
    
    func handleErrors() -> Bool{
        let errorCheck = checkFields()
        if errorCheck != nil{
            errorMessageLabel.text = errorCheck
            return false
        }else {
            errorMessageLabel.text = ""
            return true
        }
    }
    
    func changeViewControllerToHome(){
        let homeNavigationController = storyboard?.instantiateViewController(identifier: "homeNavigationController") as? UINavigationController
        view.window?.rootViewController = homeNavigationController
        view.window?.makeKeyAndVisible()
    }
    
    func registerAccountToFirebase(){
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }else {
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["firstname": firstName, "lastname": lastName, "uid": result!.user.uid]) { error in
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                }
                self.changeViewControllerToHome()
            }
        }
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        if handleErrors(){
            registerAccountToFirebase()
        }
    }
}
