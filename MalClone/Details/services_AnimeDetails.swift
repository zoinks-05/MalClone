//
//  services_AnimeDetails.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 4/5/2026.
//

import Foundation

extension AnimeView{
    // Fetch for all details related to the anime
    func fetchAll() async {
        guard id > 0 else {return}
        isLoading = true
        do {
            let json = try await APIService.shared.fetchAnimeFull(id: id)
            let bannerFetch = try await APIService.shared.fetchAniListImages(malId: id)
            let charsfetch = try await APIService.shared.getAnimeChars(id: id)
            anime = json["data"] as? [String: Any] ?? [:]
            bannerURL = ((bannerFetch["data"] as? [String: Any])?["Media"] as? [String: Any])?["bannerImage"] as? String
            characters = charsfetch["data"] as? [[String: Any]] ?? []
            print(characters)
        } catch {
            print(error.localizedDescription)
        }
        isLoading = false
    }
}
