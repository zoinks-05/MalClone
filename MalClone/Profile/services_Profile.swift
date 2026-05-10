//
//  services_Profile.swift
//  MalClone
//
//  Created by Brian Tran on 10/5/2026.
//
import Foundation

extension ProfileView {
    func fetchTotalEpisodes(id: Int) async {
        guard id > 0 else {return}
        isLoadingEpisode = true
        do {
            let json = try await APIService.shared.fetchAnimeFull(id: id)
            anime = json["data"] as? [String: Any] ?? [:]
            totalEpisodes = anime["episodes"] as? Int ?? 0
        } catch {
            print(error.localizedDescription)
        }
        isLoadingEpisode = false
    }
}
