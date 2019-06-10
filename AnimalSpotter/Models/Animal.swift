//
//  Animal.swift
//  AnimalSpotter
//
//  Created by Dongwoo Pae on 5/29/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
//animal model
class Animal: Codable {
    let id: Int
    let name: String
    let timeSeen: Date
    let latitude: Double
    let longitude: Double
    let description: String
    let imageURL: String
}
