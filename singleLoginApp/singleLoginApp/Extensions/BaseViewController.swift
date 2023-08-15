//
//  BaseViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 14/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    func loader() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Cargando...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        return alert
    }
    
    func stopLoader(loader: UIAlertController) {
     
        loader.dismiss(animated: true, completion: nil)
        
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
