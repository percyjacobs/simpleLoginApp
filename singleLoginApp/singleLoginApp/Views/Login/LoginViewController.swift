//
//  LoginViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 12/08/23.
//

import UIKit
import Firebase
import Security

class LoginViewController: BaseViewController, UITextFieldDelegate {
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
    
    func initial() {
        emailTextField.addTarget(self, action: #selector(emailDidEndEditing), for: .editingDidEnd)
        passwordTextField.addTarget(self, action: #selector(passwordDidEndEditing), for: .editingDidEnd)
        
        let toggleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(passwordToggle))
        toggleImageBtn.addGestureRecognizer(toggleGestureRecognizer)
        
        loginBtn.disable()
        registerBtn.enable()
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        emailTextField.text = ""
        passwordTextField.text = ""
        loginBtn.disable()
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
                self.showAlert(title: "Error", message: e.localizedDescription, buttonText: "Entendido")
            } else {
                let vc = HomeViewController()
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        let vc = RegisterViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    @objc func passwordToggle() {
        passwordTextField.isSecureTextEntry.toggle()
        if let textRange = passwordTextField.textRange(from: passwordTextField.beginningOfDocument, to: passwordTextField.endOfDocument) {
            passwordTextField.replace(textRange, withText: passwordTextField.text!)
        }
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
            checkData()
        }else{
            email = ""
            emailAlert.isHidden = false
            checkData()
        }
    }
    
    @objc func passwordDidEndEditing() {
        password = passwordTextField.text ?? ""
        checkData()
    }
    
    func checkData() {
        if email != "" && password != "" {
            loginBtn.enable()
        }else{
            loginBtn.disable()
        }
    }
    
}
