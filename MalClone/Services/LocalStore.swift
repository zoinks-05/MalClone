//
//  LocalStore.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import Foundation

final class LocalStore{
    static let shared = LocalStore()
    private init() { loadUser()}
    
    private let key = "user"
    private(set) var user: User = .guest
    
    private func save(){}
    
    private func loadUser(){}
    
    func updateProfile(){}
    
    func addToWatchList(){}
    
    func removeFromWatchList(){}
    
    func updateWatchList(){}
    
    func addReview(){}
    
    func deleteReview(){}
    
    func updateReview(){}
}
