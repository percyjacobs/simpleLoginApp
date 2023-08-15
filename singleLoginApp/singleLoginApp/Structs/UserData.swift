//
//  UserData.swift
//  singleLoginApp
//
//  Created by Percy Jacobs on 14/08/23.
//  Copyright © 2023 Percy Jacobs. All rights reserved.
//

import Foundation

struct UserData: Codable {
    var first: String
    var last: String
    var username: String
    var email: String
    var photo: String
}
