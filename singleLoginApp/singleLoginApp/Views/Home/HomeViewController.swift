//
//  HomeViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 13/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL
            let displayName = user.displayName
            print(user)
            print(uid)
            print(email)
            print(photoURL)
            print(displayName)
        }
    }
    
    @IBAction func logOutBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cerrar sesión", message: "¿Estás seguro de querer salir?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Sí", style: UIAlertAction.Style.default, handler: { action in
            self.logOut()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            showAlert(title: "Error", message: signOutError as! String, buttonText: "Entendido")
        }
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
