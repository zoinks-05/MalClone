//
//  services_Top.swift
//  MalClone
//
//  Created by Ethan Schweinsberg on 5/5/2026.
//
import Foundation

extension TopView
{
    func fetchTop() async
    {
        isLoading = true
        
        do
        {
            let type = switch selectedTab
            {
                case 1: "tv"
                case 2: "movie"
                case 3: "ova"
                default: ""
            }
            
            let json = try await APIService.shared.fetchTopAnime(
                type: type,
                filter: "bypopularity",
                page: 1
            )
            
            res = json["data"] as? [[String: Any]] ?? []
            
        }
        
        catch
        {
            print(error.localizedDescription)
        }
        isLoading = false
    }
}
