//
//  RegisterViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 13/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import AVKit
import Photos

class RegisterViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var shortPassAlertLabel: UILabel!
    @IBOutlet weak var passConfAlertLabel: UILabel!
    @IBOutlet weak var toggleImgBtn: UIImageView!
    @IBOutlet weak var toggleConfImgBtn: UIImageView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var selectImgLabel: UILabel!
    
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var confPassword: String = ""
    let db = Firestore.firestore()
    var loader: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initial()
    }
    
    func initial() {
        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowOffset = CGSize(width: 1, height: 2)
        imageView.layer.shadowRadius = 4
        imageView.layer.shouldRasterize = true
        imageView.layer.rasterizationScale = UIScreen.main.scale
        image.layer.cornerRadius = imageView.bounds.height / 2
        
        let chooseImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(chooseImageTapGesture)
        
        userTextField.addTarget(self, action: #selector(userDidEndEditing), for: .editingDidEnd)
        emailTextField.addTarget(self, action: #selector(emailDidEndEditing), for: .editingDidEnd)
        passwordTextField.addTarget(self, action: #selector(passwordDidEndEditing), for: .editingDidEnd)
        passwordTextField.textContentType = .oneTimeCode
        confirmPasswordTextField.addTarget(self, action: #selector(confPassDidChangeEditing), for: .editingDidEnd)
        confirmPasswordTextField.textContentType = .oneTimeCode
        
        let toggleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(passwordToggle))
        toggleImgBtn.addGestureRecognizer(toggleGestureRecognizer)
        let toggleConfGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(confPasswordToggle))
        toggleConfImgBtn.addGestureRecognizer(toggleConfGestureRecognizer)
        
        registerBtn.disable()
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                
            } else {
                
            }
        }
        
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    
                } else {}
            })
        }
    }
    
    @objc func passwordToggle() {
        passwordTextField.isSecureTextEntry.toggle()
        if let textRange = passwordTextField.textRange(from: passwordTextField.beginningOfDocument, to: passwordTextField.endOfDocument) {
            passwordTextField.replace(textRange, withText: passwordTextField.text!)
        }
        toggleImgBtn.image = passwordTextField.isSecureTextEntry ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
    }
    
    @objc func confPasswordToggle() {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        if let textRange = confirmPasswordTextField.textRange(from: confirmPasswordTextField.beginningOfDocument, to: confirmPasswordTextField.endOfDocument) {
            confirmPasswordTextField.replace(textRange, withText: confirmPasswordTextField.text!)
        }
        toggleConfImgBtn.image = confirmPasswordTextField.isSecureTextEntry ? UIImage(systemName: "eye.slash") : UIImage(systemName: "eye")
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        if image.image != UIImage(systemName: "photo.circle"){
            register()
        }else{
            showAlert(title: "Información", message: "No ha seleccionado imagen para completar el registro.", buttonText: "Entendido")
        }
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                self.showAlert(title: "Error", message: e.localizedDescription, buttonText: "Entendido")
            } else {
                self.uploadImage()
            }
        }
    }
    
    func updateData(image: URL) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
                self.showAlert(title: "Error", message: e.localizedDescription, buttonText: "Entendido")
            }else{
                let user = Auth.auth().currentUser
                if let user = user {
                    self.saveDataDB(image: image, uid: user.uid)
                }
            }
        }
    }
    
    func saveDataDB(image: URL, uid: String) {
        let data: [String: Any] = [
            "first": "",
            "last": "",
            "username": username,
            "email": email,
            "photo": image.absoluteString
        ]
        
        db.collection("users").document(uid).setData(data) { error in
            if let error {
                self.showAlert(title: "Error", message: error.localizedDescription, buttonText: "Entendido")
                self.signOut()
            } else {
                self.signOut()
            }
        }
    }
    
    func uploadImage() {
        loader = loader()
        let user = Auth.auth().currentUser
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        if let data = image.image?.jpegData(compressionQuality: 0.5) {
            let imageReference = mediaFolder.child("\(user!.uid).jpg")
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.showAlert(title: "Error!", message: error?.localizedDescription ?? "Error!", buttonText: "Entendido")
                } else {
                    imageReference.downloadURL { url, error in
                        self.stopLoader(loader: self.loader!)
                        if error == nil {
                            self.updateData(image: url ?? URL(string: "https://example.com/jane-q-user/profile.jpg")!)
                        }else{
                            self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error inesperado.", buttonText: "Entendido")
                        }
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            let alert = UIAlertController(title: "Registro Exitoso", message: "Se ha creado el usuario correctamente.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Entendido", style: UIAlertAction.Style.default, handler: { action in
                self.view.window?.rootViewController?.dismiss(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        } catch let signOutError as NSError {
            showAlert(title: "Error", message: signOutError as! String, buttonText: "Entendido")
        }
    }
    
    @objc func userDidEndEditing() {
        username = userTextField.text ?? ""
    }
    
    @objc func emailDidEndEditing() {
        if isValidEmail(emailTextField.text ?? "") {
            email = emailTextField.text ?? ""
            emailAlertLabel.isHidden = true
        }else{
            email = ""
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
        if (passwordTextField.text?.count ?? 0) > 5 {
            password = passwordTextField.text ?? ""
            shortPassAlertLabel.isHidden = true
            checkData()
        }else{
            password = passwordTextField.text ?? ""
            shortPassAlertLabel.isHidden = false
            checkData()
        }
    }
    
    @objc func confPassDidChangeEditing() {
        confPassword = confirmPasswordTextField.text ?? ""
        
        if password == confPassword {
            passConfAlertLabel.isHidden = true
            checkData()
        }else{
            passConfAlertLabel.isHidden = false
            checkData()
        }
    }
    
    func checkData() {
        if username != "" && email != "" && shortPassAlertLabel.isHidden && password == confPassword {
            registerBtn.enable()
        }else{
            registerBtn.disable()
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.originalImage] as? UIImage
        selectImgLabel.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func chooseImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}
