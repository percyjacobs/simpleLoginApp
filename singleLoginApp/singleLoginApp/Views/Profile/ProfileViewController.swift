//
//  ProfileViewController.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 13/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
    @IBAction func backBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func initial(){
        imageView.layer.cornerRadius = 20
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width: 1, height: 2)
        imageView.layer.shadowRadius = 2
        imageView.layer.shouldRasterize = true
        imageView.layer.rasterizationScale = UIScreen.main.scale
    }
}
