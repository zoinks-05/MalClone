//
//  extension_Search.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 4/5/2026.
//

import SwiftUI

extension SearchView {
    
    // Anime grid
    var CardLogic: some View{
        GeometryReader { geo in
            
            // Responsive columns
            let col = columns(for: geo.size.width)
            let gridItems: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: col)
            
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 16)  {
                    // Anime Card
                    ForEach(res.indices, id: \.self) { i in
                        let anime = res[i]
                        VStack(spacing: 0) {
                            // Cover
                            AsyncImage(url: imageURL(anime)) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    Color.secondary.opacity(0.2)
                                }
                            }
                            .frame(width: 175,  height: 265)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            // Info
                            let isAiring = anime["airing"] as? Bool ?? false
                            VStack(alignment: .leading, spacing: 4) {
                                HStack{
                                    Image(systemName: isAiring ? "dot.radiowaves.left.and.right" : "pause.circle")
                                        .foregroundStyle(isAiring ? .purple : .secondary)
                                    Text(anime["title"] as? String ?? "Unknown")
                                        .font(.headline)
                                }
                                .lineLimit(1)
                                .padding(.top)
                                .padding(.bottom, 2)
                                HStack(spacing: 6){
                                    tags(anime)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                        }
                        // Open anime details
                        .onTapGesture {
                            if let id = anime["mal_id"] as? Int {
                                selectedId = AnimeID(id: id)
                            }
                        }
                        .padding(6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        
                        // Infinte scrolling
                        .onAppear {
                            if i ==  res.count - 1{
                                Task { await nextPage()}
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    // Bottom loading indicator
                    if isFetchingMore{
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .gridCellColumns(col)
                    }
                }
            }
            // Anime details sheet
            .sheet(item: $selectedId) { animeID in
                NavigationStack {
                    AnimeView(id: animeID.id)
                }
            }
        }
    }

}
