//
//  APIcall.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//

import Foundation

private let jikanBaseURL = "https://api.jikan.moe/v4"
private let aniListURL   = "https://graphql.anilist.co"

final class APIService {
    static let shared = APIService()
    private init() {}

    private func fetch(_ urlString: String) async throws -> [String: Any] {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }

    func fetchAnimeFull(id: Int) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime/\(id)/full")
    }

    func searchAnime(query: String, limit: Int = 5) async throws -> [String: Any] {
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await fetch("\(jikanBaseURL)/anime?q=\(q)&limit=\(limit)")
    }

    func searchAnimePaged(query: String, page: Int = 1) async throws -> [String: Any] {
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await fetch("\(jikanBaseURL)/anime?q=\(q)&limit=25&page=\(page)")
    }

    func fetchTopAnime() async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/top/anime?limit=25")
    }

    func fetchSeasonalAnime() async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/seasons/now?limit=25")
    }

    func fetchGenres() async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/genres/anime")
    }

    func fetchAnimeByGenre(genreId: Int, page: Int = 1) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime?genres=\(genreId)&limit=25&page=\(page)")
    }

    func fetchEpisodes(id: Int, page: Int = 1) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime/\(id)/episodes?page=\(page)")
    }

    func fetchCharacters(id: Int) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime/\(id)/characters")
    }

    func fetchStaff(id: Int) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime/\(id)/staff")
    }

    func fetchRecommendations(id: Int) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime/\(id)/recommendations")
    }

    func fetchPictures(id: Int) async throws -> [String: Any] {
        return try await fetch("\(jikanBaseURL)/anime/\(id)/pictures")
    }
    
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
