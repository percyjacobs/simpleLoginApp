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
        self.backgroundColor = UIColor.systemCyan
        self.setTitleColor(.white, for: .normal)
        self.isEnabled = true
        self.layer.cornerRadius = 5
    }
    
    func disable(){
        self.backgroundColor = UIColor.systemGray4
        self.setTitleColor(.white, for: .disabled)
        self.isEnabled = false
        self.layer.cornerRadius = 5
    }
}
