//
//  extension_home.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 10/5/2026.
//

import SwiftUI

extension HomeView {
    
    // generic home tab structure
    func homeTab(data: [[String:Any]], dataPage: Binding<Int>, Title: String, fetch: @escaping (Int) async -> Void) -> some View {
        VStack(alignment: .leading){
            HStack{
                Text(Title)
                    .font(.title.bold())
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 12){
                    ForEach(data.indices, id: \.self) { i in
                        let anime = data[i]
                        let malId = anime["mal_id"] as? Int ?? 0
                        VStack(spacing: 0){
                            AsyncImage(url: imageURL(anime)){ s in
                                switch s {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    Color.gray.opacity(0.2)
                                }
                            }
                            .onTapGesture {
                                selectedId = malId
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05){
                                    showDetails = true
                                }
                            }
                        }
                        .onAppear{
                            if i == data.count - 1 {
                                dataPage.wrappedValue += 1
                                Task { await fetch(dataPage.wrappedValue)}
                            }
                        }
                    }
                }
            }
            
            Divider()
                .padding()
        }
    }
    
    // Carasoul card ui
    func caraCard(anime: [String:Any], malId: Int) -> some View{
        VStack(alignment: .leading){
            Spacer()
            
            // Title
            HStack{
                Text(anime["title"] as? String ?? "")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Spacer()
            }
            if let synopsis = anime["synopsis"] as? String {
                Text(synopsis)
                    .foregroundStyle(.white)
                    .font(.caption)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            
            // banner image
            AsyncImage(url: URL(string: banners[malId] ?? "")){ s in
                switch s {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Color.gray.opacity(0.2)
                }
            }
            .id(malId)
            // dark fradient overlay
            .overlay(
                LinearGradient(colors: [Color.clear, Color.black.opacity(1)], startPoint: .top, endPoint: .bottom)
            )
            .onTapGesture {
                selectedId = malId
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05){
                    showDetails = true
                }
            }
        )
    }
}
