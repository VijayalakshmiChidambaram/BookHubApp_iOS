//
//  Favorites.swift
//  bookHub
//
//  Created by Jude Vergara on 11/30/21.
//

import Foundation

class Favorites {
    static let sharedInstance = Favorites()
    var favorites = [String]()
    var username = "username"
    var isGuest = false
}
