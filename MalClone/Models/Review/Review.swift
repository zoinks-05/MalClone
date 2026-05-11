//
//  Review.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//
import Foundation

// Review model for anime
struct Review: Codable, Identifiable {
    var id: UUID = UUID()
    var animeId: Int
    var title: String
    var body: String
    var isSpoiler: Bool
}
