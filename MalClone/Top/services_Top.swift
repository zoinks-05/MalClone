//
//  services_Top.swift
//  MalClone
//
//  Created by Ethan Schweinsberg on 5/5/2026.
//
import Foundation

extension TopView
{
    // fetch first page of top anime
    func fetchTop() async {
        isLoading = true
        currentPage = 1
        
        do {
            let type = switch selectedTab {
                case 1: "tv"
                case 2: "movie"
                case 3: "ova"
                default: " "
            }
            
            // fetch from API
            let json = try await APIService.shared.fetchTopAnime(
                type: type,
                filter: "bypopularity",
                page: 1
            )
            
            res = json["data"] as? [[String: Any]] ?? []
            pageData = json["pagination"] as? [String: Any] ?? [:]
            
        }
        
        catch {
            print(error.localizedDescription)
        }
        isLoading = false
    }
    
    // fetch next page when at end of page
    func nextPage() async {
        // stop if no new pages
        guard !isFetchingMore, pageData["has_next_page"] as? Bool == true else { return }
        isFetchingMore = true
        currentPage += 1
        
        do {
            let type: String
            
            switch selectedTab {
                case 1: type = "tv"
                case 2: type = "movie"
                case 3: type = "ova"
                default: type = ""
            }
            
            // fetch next page
            let json = try await APIService.shared.fetchTopAnime(
                type: type,
                filter: "bypopularity",
                page: currentPage
            )
            
            let newItems = json["data"] as? [[String: Any]] ?? []
            pageData = json["pagination"] as? [String: Any] ?? [:]
            res.append(contentsOf: newItems)
        }
    
        
        catch {
            print(error.localizedDescription)
        }
        isFetchingMore = false
    }
}
