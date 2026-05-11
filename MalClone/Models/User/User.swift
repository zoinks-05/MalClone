//
//  User.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//

import Foundation

// User model storing profile data
struct User: Codable{
    var id: UUID = UUID()
    var name: String
    var bio: String
    var watchlist: [WatchListEntry]
    var reviews: [Review]
    
    // default guest user
    static var guest = User(name: "Guest", bio: "", watchlist: [], reviews: [])
}
