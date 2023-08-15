//
//  ProfileViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 13/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: BaseViewController, UITextFieldDelegate  {
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var selectImgLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    let db = Firestore.firestore()
    var username: String = ""
    var firstname: String = ""
    var lastname: String = ""
    var email: String = ""
    var userData: UserData?
    var loader: UIAlertController?
    var imageChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initial()
    }
    
    
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func editData(_ sender: UIButton) {
        usernameTextField.isUserInteractionEnabled = !usernameTextField.isUserInteractionEnabled
        nameTextField.isUserInteractionEnabled = !nameTextField.isUserInteractionEnabled
        lastnameTextField.isUserInteractionEnabled = !lastnameTextField.isUserInteractionEnabled
        emailTextField.isUserInteractionEnabled = !emailTextField.isUserInteractionEnabled
        imageView.isUserInteractionEnabled = !imageView.isUserInteractionEnabled
        selectImgLabel.isHidden = !selectImgLabel.isHidden
        
        usernameTextField.backgroundColor = usernameTextField.isUserInteractionEnabled ? UIColor.white : UIColor.systemGray5
        nameTextField.backgroundColor = nameTextField.isUserInteractionEnabled ? UIColor.white : UIColor.systemGray5
        lastnameTextField.backgroundColor = lastnameTextField.isUserInteractionEnabled ? UIColor.white : UIColor.systemGray5
        emailTextField.backgroundColor = emailTextField.isUserInteractionEnabled ? UIColor.white : UIColor.systemGray5
    }
    
    func initial(){
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
        
        usernameTextField.addTarget(self, action: #selector(userDidEndEditing), for: .editingDidEnd)
        nameTextField.addTarget(self, action: #selector(nameDidEndEditing), for: .editingDidEnd)
        lastnameTextField.addTarget(self, action: #selector(lastnameDidEndEditing), for: .editingDidEnd)
        emailTextField.addTarget(self, action: #selector(emailDidEndEditing), for: .editingDidEnd)
        
        
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            
            getData(userID: uid)
        }
        
        updateBtn.disable()
    }
    
    @objc func userDidEndEditing() {
        username = usernameTextField.text ?? ""
        checkData()
    }
    
    @objc func nameDidEndEditing() {
        firstname = nameTextField.text ?? ""
        checkData()
    }
    
    @objc func lastnameDidEndEditing() {
        lastname = lastnameTextField.text ?? ""
        checkData()
    }
    
    @objc func emailDidEndEditing() {
        if isValidEmail(emailTextField.text ?? "") {
            email = emailTextField.text ?? ""
            emailAlertLabel.isHidden = true
            checkData()
        }else{
            email = ""
            emailAlertLabel.isHidden = false
            checkData()
        }
    }
    
    func getData(userID: String) {
        DispatchQueue.main.async {
            self.loader = self.loader()
        }
        
        let docRef = db.collection("users").document(userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.userData = self.decoderFunc(doc: document)
                self.fillView()
            } else {
                self.showAlert(title: "Error", message: "Usuario no existe.", buttonText: "Entendido")
            }
        }
    }
    
    func fillView() {
        usernameTextField.text = userData?.username
        nameTextField.text = userData?.first
        lastnameTextField.text = userData?.last
        emailTextField.text = userData?.email
        
        username = userData?.username ?? ""
        firstname = userData?.first ?? ""
        lastname = userData?.last ?? ""
        email = userData?.email ?? ""
        
        setImageFromStringrURL(stringUrl: userData!.photo)
    }
    
    func setImageFromStringrURL(stringUrl: String) {
        if let url = URL(string: stringUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                    self.image.image = UIImage(data: imageData)
                    self.stopLoader(loader: self.loader!)
                }
            }.resume()
        }
    }
    
    @IBAction func updateBtnPressed(_ sender: UIButton) {
        updateData()
    }
    
    func updateData() {
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription, buttonText: "Entendido")
            }else{
                if self.imageChanged {
                    self.uploadImage()
                }else{
                    self.downloadImage()
                }
            }
        }
    }
    
    func saveDataDB(image: URL, uid: String) {
        let data: [String: Any] = [
            "first": firstname,
            "last": lastname,
            "username": username,
            "email": email,
            "photo": image.absoluteString
        ]
        
        db.collection("users").document(uid).setData(data) { error in
            if let error {
                self.showAlert(title: "Error", message: error.localizedDescription, buttonText: "Entendido")
            } else {
                self.editData(self.editBtn)
                self.updateBtn.disable()
                
                let alert = UIAlertController(title: "Actualización exitosa", message: "Se ha realizado la actualización de datos.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Entendido", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func uploadImage() {
        imageChanged = false
        loader = self.loader()
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
                            self.saveDataDB(image: url ?? URL(string: "")!, uid: user!.uid)
                        }else{
                            self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error inesperado", buttonText: "Entendido")
                        }
                    }
                }
            }
        }
    }
    
    func downloadImage() {
        loader = self.loader()
        let user = Auth.auth().currentUser
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        let imageReference = mediaFolder.child("\(user!.uid).jpg")
        imageReference.downloadURL { url, error in
            self.stopLoader(loader: self.loader!)
            if error == nil {
                self.saveDataDB(image: url ?? URL(string: "")!, uid: user!.uid)
            }else{
                print("Error download \(error)")
                self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error inesperado", buttonText: "Entendido")
            }
        }
    }
    
    func checkData() {
        if firstname != "" && lastname != "" && username != "" && email != "" {
            updateBtn.enable()
        }else{
            updateBtn.disable()
        }
    }
    
    func decoderFunc(doc: DocumentSnapshot) -> UserData {
        let decoder = JSONDecoder()
        let dict = doc.data()
        
        if let data = try?  JSONSerialization.data(withJSONObject: dict!, options: []) {
            let userD = try? decoder.decode(UserData.self, from: data)
            return userD!
        }
        
        return UserData(first: "", last: "", username: "", email: "", photo: "")
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.originalImage] as? UIImage
        selectImgLabel.isHidden = true
        imageChanged = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func chooseImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}
