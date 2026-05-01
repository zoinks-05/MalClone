//
//  AnimeDetails.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 1/5/2026.
//

import SwiftUI

struct AnimeView: View{
    @State private var isLoading: Bool = false
    @State private var anime: [String: Any] = [:]
    @State private var bannerURL: String? = nil
    let id: Int
    
    var body: some View{
        VStack(spacing: 0) {
            if isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                HStack(alignment: .bottom){
                    AsyncImage(url: imageURL(anime)){ s in
                        switch s {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 6){
                        
                        Text(anime["title"] as? String ?? "Unknown Title")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack(spacing: 10){
                            Text(String(format: "%.2f", anime["score"] as? Double ?? 0.0))
                                .font(.caption)
                                .foregroundColor(.white)
                            Text((anime["studios"] as? [[String: Any]])?.first?["name"] as? String ?? "Unknown Studio")
                                .font(.caption)
                                .foregroundColor(.white)
                            Button{
                                
                            } label: {
                                Text("More Info")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                .frame(height: 250)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    AsyncImage(url: URL(string: bannerURL ?? "")){ s in
                        switch s {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            Color.secondary.opacity(0.2)
                        }
                    }
                    .clipped()
                    .overlay(
                        LinearGradient(colors: [Color.clear, Color.black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                    )
                )
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task{ await fetchAll() }
        
    }
    
    func imageURL(_ anime: [String: Any]) -> URL? {
        let images = anime["images"] as? [String: Any]
        let jpg    = images?["jpg"]  as? [String: Any]
        return URL(string: jpg?["image_url"] as? String ?? "")
    }
    
    func fetchAll() async {
        guard id > 0 else {return}
        isLoading = true
        do {
            let json = try await APIService.shared.fetchAnimeFull(id: id)
            let bannerFetch = try await APIService.shared.fetchAniListImages(malId: id)
            anime = json["data"] as? [String: Any] ?? [:]
            bannerURL = ((bannerFetch["data"] as? [String: Any])?["Media"] as? [String: Any])?["bannerImage"] as? String
            print(anime)
        } catch {
            print(error.localizedDescription)
        }
        isLoading = false
    }
}
