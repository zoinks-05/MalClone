//
//  services_Home.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 10/5/2026.
//

import SwiftUI

extension HomeView {
    // inital data load
    func loadInit() async {
        guard !Task.isCancelled else {return}
        
        do {
            // Carasoul fetch
            let json = try await APIService.shared.fetchCarasoulAnime()
            if Task.isCancelled { return }
            caraDeets = json["data"] as? [[String: Any]] ?? []
            
            // load main section
            await getSeasonal()
            if Task.isCancelled { return }

            await getTop()
            if Task.isCancelled { return }
            
            // fetch upcoing anime
            await getUpcoming()
            if Task.isCancelled { return }

            // load genre fetch
            let randomIndices = Array(genres.indices).shuffled().prefix(3)
            for g in randomIndices {
                if Task.isCancelled { return }
                await getGenre(genreIndex: g)
            }
            // fetch banner
            await getBanner()
            if Task.isCancelled { return }

        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Fetch banner images
    func getBanner() async {
        for anime in caraDeets{
            guard let malid = anime["mal_id"] as? Int else {continue}
            let res = try? await APIService.shared.fetchAniListImages(malId: malid)
            let media = (res?["data"] as? [String: Any])?["Media"] as? [String: Any]
            if let banner = media?["bannerImage"] as? String{
                banners[malid] = banner
            }
        }
        
        // UI is ready after banners load
        isReady = true
    }
        
    // get seasonal
    func getSeasonal(page: Int = 1) async {
        do {
            let json_seasonal = try await APIService.shared.fetchSeasonalAnime(page: page)
            if page == 1 {
                seasonalDeets = json_seasonal["data"] as? [[String: Any]] ?? []
            } else {
                seasonalDeets.append(contentsOf: json_seasonal["data"] as? [[String: Any]] ?? [])
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // get top
    func getTop(page: Int = 1) async {
        do {
            let json_top = try await APIService.shared.fetchTopAnime(page: page)
            if page == 1 {
                topDeets = json_top["data"] as? [[String: Any]] ?? []
            } else {
                topDeets.append(contentsOf: json_top["data"] as? [[String: Any]] ?? [])
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // get upcoming animes
    func getUpcoming(page: Int = 1) async {
        do {
            let json_Upcoming = try await APIService.shared.fetchUpcomingAnime(page: page)
            if page == 1 {
                upcomingDeets = json_Upcoming["data"] as? [[String: Any]] ?? []
            } else {
                upcomingDeets.append(contentsOf: json_Upcoming["data"] as? [[String: Any]] ?? [])
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    // get specific genre
    func getGenre(genreIndex: Int, page: Int = 1) async {
        do {
            let json_genre = try await APIService.shared.fetchAnimeByGenre(genreId: genres[genreIndex].id, page: page)
            if page == 1 {
                genreDeets[genreIndex] = json_genre["data"] as? [[String: Any]] ?? []
            } else {
                genreDeets[genreIndex].append(contentsOf: json_genre["data"] as? [[String: Any]] ?? [])
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
