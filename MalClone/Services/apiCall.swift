//
//  APIcall.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//

import Foundation

// Jikan ordering types
enum OrderBy: String, CaseIterable {
    case title     = "title"
    case startDate = "start_date"
    case endDate   = "end_date"
    case episodes  = "episodes"
    case score     = "score"
    case scoredBy  = "scored_by"
    case rank      = "rank"
    case popularity = "popularity"
    case members   = "members"
    case favorites = "favorites"
}

// Urls sources
private let jikanBaseURL = "https://api.jikan.moe/v4"
private let aniListURL   = "https://graphql.anilist.co"

final class APIService {
    // Shared instance
    static let shared = APIService()
    private init() {}

    // generlised api fetch to make conversetion to JSON simpler
    private func fetch(_ urlString: String) async throws -> [String: Any] {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }

    // Fetch full anime details
    func fetchAnimeFull(id: Int) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime/\(id)/full")
    }
    
    // Fetch Anime characters
    func getAnimeChars(id: Int) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime/\(id)/characters")
    }

    // Fetch anime by search
    func searchAnimePaged(query: String, page: Int = 1, orderBy: OrderBy = OrderBy.popularity, sort: String = "desc") async throws -> [String: Any] {
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await fetch("\(jikanBaseURL)/anime?q=\(q)&limit=25&page=\(page)&order_by=\(orderBy.rawValue)&sort=\(sort)")
    }

    // Fetch top anime list
    func fetchTopAnime(type: String = "", filter: String = "", page: Int = 1) async throws -> [String: Any] {
        var path = "\(jikanBaseURL)/top/anime?limit=25&filter=\(filter)&page=\(page)"
        // Add anime type if selected
        if !type.isEmpty { path += "&type=\(type)" }
        return try await fetch(path)
    }

    // Fetch currently airing anime
    func fetchSeasonalAnime(page: Int = 1) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/seasons/now?limit=10&page=\(page)")
    }
    
    // Fetch upcoming animes
    func fetchUpcomingAnime(page: Int = 1) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/seasons/upcoming?limit=10&page=\(page)")
    }
    
    // Fetch carasoul animes
    func fetchCarasoulAnime() async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/seasons/now?limit=6")
    }

    // Fetch anime by genre
    func fetchAnimeByGenre(genreId: Int, page: Int = 1) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime?genres=\(genreId)&limit=10&page=\(page)")
    }
    
    
    // Fetch aniList banners
    func fetchAniListImages(malId: Int) async throws -> [String: Any] {
        let query = """
        query ($malId: Int) {
          Media(idMal: $malId, type: ANIME) {
            id
            idMal
            coverImage { extraLarge large medium }
            bannerImage
          }
        }
        """
        guard let url = URL(string: aniListURL) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "query": query,
            "variables": ["malId": malId]
        ])
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
}
