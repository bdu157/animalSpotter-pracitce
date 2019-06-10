//
//  User.swift
//  AnimalSpotter
//
//  Created by Dongwoo Pae on 5/29/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
//what we need to POST
struct User: Codable {
    let username: String
    let password: String
}
