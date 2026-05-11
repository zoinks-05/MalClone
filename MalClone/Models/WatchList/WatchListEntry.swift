//
//  WatchListEntry.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//
import Foundation

// Status of anime in a users watchlist
enum WatchStatus: String, Codable, CaseIterable{
    case watching = "Watching"
    case completed = "Completed"
    case planToWatch = "Plan to Watch"
    case dropped = "Dropped"
}

// Single watchlist entry for an anime
struct WatchListEntry: Codable, Identifiable {
    var id: Int
    var title: String
    var epsWatched: Int
    var status: WatchStatus
    var score: Int?
}
