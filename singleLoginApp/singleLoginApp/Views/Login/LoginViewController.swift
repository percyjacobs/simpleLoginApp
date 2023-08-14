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
    @IBOutlet weak var emailAlert: UILabel!
    @IBOutlet weak var toggleImageBtn: UIImageView!
    
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
                    let vc = HomeViewController()
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        let vc = RegisterViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    func initial() {
        let toolBar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnTapped))
        
        toolBar.setItems([flexSpace, doneButton], animated: true)
        toolBar.sizeToFit()
        emailTextField.inputAccessoryView = toolBar
        passwordTextField.inputAccessoryView = toolBar
        
        emailTextField.addTarget(self, action: #selector(emailDidEndEditing), for: .editingDidEnd)
        passwordTextField.addTarget(self, action: #selector(passwordDidEndEditing), for: .editingDidEnd)
        
        let toggleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(passwordToggle))
        toggleImageBtn.addGestureRecognizer(toggleGestureRecognizer)
        
        loginBtn.disable()
    }
    
    @objc func doneBtnTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc func passwordToggle() {
        passwordTextField.isSecureTextEntry.toggle()
        toggleImageBtn.image = passwordTextField.isSecureTextEntry ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @objc func emailDidEndEditing() {
        if isValidEmail(emailTextField.text ?? ""){
            emailAlert.isHidden = true
            email = emailTextField.text ?? ""
        }else{
            emailAlert.isHidden = false
            loginBtn.disable()
        }
    }
    
    @objc func passwordDidEndEditing() {
        password = passwordTextField.text ?? ""
        loginBtn.enable()
    }
    
}
