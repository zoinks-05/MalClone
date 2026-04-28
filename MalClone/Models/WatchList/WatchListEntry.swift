//
//  WatchListEntry.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//
import Foundation

enum WatchStatus: String, Codable, CaseIterable{
    case watching = "Watching"
    case completed = "Completed"
    case planToWatch = "Plan to Watch"
    case dropped = "Dropped"
}

struct WatchListEntry: Codable, Identifiable {
    var id: Int
    var title: String
    var status: WatchStatus
    var score: Int?
}
