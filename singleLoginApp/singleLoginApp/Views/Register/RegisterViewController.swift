//
//  RegisterViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 13/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var toggleImgBtn: UIImageView!
    @IBOutlet weak var toggleConfImgBtn: UIImageView!
    
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var confPassword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initial()
    }

    
    func initial() {
        let toolBar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnTapped))
        
        toolBar.setItems([flexSpace, doneButton], animated: true)
        toolBar.sizeToFit()
        userTextField.inputAccessoryView = toolBar
        emailTextField.inputAccessoryView = toolBar
        passwordTextField.inputAccessoryView = toolBar
        confirmPasswordTextField.inputAccessoryView = toolBar
        
        emailTextField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        passwordTextField.addTarget(self, action: #selector(passwordDidEndEditing), for: .editingDidEnd)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChangeSelection), for: .editingChanged)
        
        let toggleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(passwordToggle))
        toggleImgBtn.addGestureRecognizer(toggleGestureRecognizer)
        let toggleConfGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(confPasswordToggle))
        toggleConfImgBtn.addGestureRecognizer(toggleConfGestureRecognizer)
        
        registerBtn.disable()
    }
    
    @objc func doneBtnTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
    
    @objc func passwordToggle() {
        passwordTextField.isSecureTextEntry.toggle()
        toggleImgBtn.image = passwordTextField.isSecureTextEntry ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
    }
    
    @objc func confPasswordToggle() {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        toggleConfImgBtn.image = confirmPasswordTextField.isSecureTextEntry ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        if username != "" && email != "" {
            register()
        }else{
            print("FRACASO")
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print(e)
            } else {
                self.updateData()
            }
        }
    }
    
    func updateData() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print(e)
            }else{
                let user = Auth.auth().currentUser
                print(user)
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    
                    changeRequest.displayName = self.username
                    changeRequest.photoURL =
                    URL(string: "https://example.com/jane-q-user/profile.jpg")
                    changeRequest.commitChanges { error in
                        print(error)
                    }
                    self.signOut()
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch let signOutError as NSError {
            showAlert(title: "Error", message: signOutError as! String, buttonText: "Entendido")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        username = userTextField.text ?? ""
        
        if isValidEmail(emailTextField.text ?? "") {
            email = emailTextField.text ?? ""
            emailAlertLabel.isHidden = true
        }else{
            registerBtn.disable()
            emailAlertLabel.isHidden = false
        }
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @objc func passwordDidEndEditing() {
        password = passwordTextField.text ?? ""
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        confPassword = confirmPasswordTextField.text ?? ""
        
        if password == confPassword {
            registerBtn.enable()
        }else{
            registerBtn.disable()
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func showAlert(title: String, message: String, buttonText: String, buttonText2: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.default, handler: nil))
        if let buttonText2 {
            alert.addAction(UIAlertAction(title: buttonText2, style: UIAlertAction.Style.cancel, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
}
