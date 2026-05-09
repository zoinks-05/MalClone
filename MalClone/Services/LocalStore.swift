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
    
    private func save(){
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadUser(){
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(User.self, from: data)
        else {return}
        user = decoded
    }
    
    func updateProfile(name: String, bio: String){
        user.name = name
        user.bio = bio
        save()
    }
    
    func addToWatchList(id: Int, title: String, status: WatchStatus, score: Int?, epsWatched: Int){
        guard !user.watchlist.contains(where: {$0.id == id}) else { return }
        user.watchlist.append(WatchListEntry(id:id,title: title, epsWatched: epsWatched, status: status, score: score))
        save()
    }
    
    func removeFromWatchList(id: Int){
        user.watchlist.removeAll {$0.id == id}
        user.reviews.removeAll {$0.animeId == id}
        save()
    }
    
    func isEntered(id: Int) -> Bool? {
        user.watchlist.contains {$0.id == id}
    }
    
    func getWatchlist(id: Int) -> WatchListEntry? {
        user.watchlist.first {$0.id == id}
    }
    
    func getReviews(id: Int) -> [Review] {
        user.reviews.filter {$0.animeId == id}
    }
    
    func updateWatchList(id:Int, status: WatchStatus, score: Int?, epsWatched: Int?){
        guard let i = user.watchlist.firstIndex(where: {$0.id == id}) else { return }
        user.watchlist[i].status = status
        user.watchlist[i].score = score
        user.watchlist[i].epsWatched = epsWatched!
        save()
    }
    
    func addReview(Id: Int, title: String, body: String, isSpoiler: Bool){
        user.reviews.insert(Review(animeId: Id, title: title, body: body, isSpoiler: isSpoiler), at: 0)
        save()
    }
    
    func deleteReview(id: UUID){
        user.reviews.removeAll {$0.id == id}
        save()
    }
    
    func updateReview(id: UUID, title: String, body: String, isSpoiler: Bool){
        guard let i = user.reviews.firstIndex(where: {$0.id == id}) else { return }
        user.reviews[i].title = title
        user.reviews[i].body = body
        user.reviews[i].isSpoiler = isSpoiler
        save()
    }
}
