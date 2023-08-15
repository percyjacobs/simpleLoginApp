//
//  HomeViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 13/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: BaseViewController {
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var logOutView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initial()
    }
    
    func initial() {
        profileView.layer.cornerRadius = 10
        profileView.layer.shadowColor = UIColor.gray.cgColor
        profileView.layer.shadowOpacity = 0.4
        profileView.layer.shadowOffset = CGSize(width: 1, height: 2)
        profileView.layer.shadowRadius = 3
        profileView.layer.shouldRasterize = true
        profileView.layer.rasterizationScale = UIScreen.main.scale
        logOutView.layer.cornerRadius = 10
        logOutView.layer.shadowColor = UIColor.gray.cgColor
        logOutView.layer.shadowOpacity = 0.4
        logOutView.layer.shadowOffset = CGSize(width: 1, height: 2)
        logOutView.layer.shadowRadius = 3
        logOutView.layer.shouldRasterize = true
        logOutView.layer.rasterizationScale = UIScreen.main.scale
        
        let profileGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        profileView.addGestureRecognizer(profileGestureRecognizer)
        let logOutGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logOut))
        logOutView.addGestureRecognizer(logOutGestureRecognizer)
    }
    
    @IBAction func logOutBtnPressed(_ sender: UIBarButtonItem) {
        logOut()
    }
    
    @objc func profileTapped() {
        let vc = ProfileViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    @objc func logOut() {
        let alert = UIAlertController(title: "Cerrar sesión", message: "¿Está seguro de querer salir?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Sí", style: UIAlertAction.Style.default, handler: { action in
            self.logOutService()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func logOutService() {
        do {
            try Auth.auth().signOut()
            self.view.window?.rootViewController?.dismiss(animated: true)
        } catch let signOutError as NSError {
            showAlert(title: "Error", message: signOutError as! String, buttonText: "Entendido")
        }
    }
}
