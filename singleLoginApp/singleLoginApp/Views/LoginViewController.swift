//
//  LoginViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 12/08/23.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    var email: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initial()
    }

    @IBAction func loginBtnPressed(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
//                    mvc.modalPresentationStyle = .overCurrentContext
                    //        mvc.modalTransitionStyle = .crossDissolve
                    //
                    //        self.present(mvc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        
    }
    
    func initial() {
        loginBtn.layer.cornerRadius = 5
        registerBtn.layer.cornerRadius = 5
        
        let toolBar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnTapped))
        
        toolBar.setItems([flexSpace, doneButton], animated: true)
        toolBar.sizeToFit()
        emailTextField.inputAccessoryView = toolBar
        passwordTextField.inputAccessoryView = toolBar
        
        emailTextField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        passwordTextField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        
        
    }
    
    @objc func doneBtnTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        email = emailTextField.text ?? ""
        password = passwordTextField.text ?? ""
        
    }
    
}
