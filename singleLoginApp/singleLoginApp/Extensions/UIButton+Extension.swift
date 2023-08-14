//
//  UIButton+Extension.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 13/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    
    func enable(){
        self.backgroundColor = UIColor.cyan
        self.setTitleColor(.white, for: .normal)
        self.isEnabled = true
        self.layer.cornerRadius = 5
    }
    
    func disable(){
        self.isEnabled = false
        self.backgroundColor = UIColor.systemGray
        self.layer.cornerRadius = 5
    }
}
