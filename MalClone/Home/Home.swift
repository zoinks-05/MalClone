//
//  Home.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

struct HomeView: View{
    @State   var caraDeets: [[String: Any]] = []
    @State   var seasonalDeets: [[String: Any]] = []
    @State   var topDeets: [[String: Any]] = []
    @State   var upcomingDeets: [[String: Any]] = []
    @State   var banners: [Int: String] = [:]
    @State   var currentIndex = 0
    @State   var showDetails: Bool = false
    @State   var selectedId: Int = 0
    @State   var isReady: Bool = false
    @State   var currentSeasonalPage = 1
    @State   var currentTopPage = 1
    @State   var upcomingPage = 1
    @State   var genres: [(id: Int, name: String)] = [ (1, "Action"),
                                                   (2, "Adventure"),
                                                   (4, "Comedy"),
                                                   (8, "Drama"),
                                                   (10, "Fantasy"),
                                                   (14, "Horror"),
                                                   (7, "Mystery"),
                                                   (22, "Romance"),
                                                   (24, "Sci-Fi")]
    @State   var genreDeets: [[[String: Any]]] = Array(repeating: [], count: 9)
    @State   var currentGenrePage = Array(repeating: 1, count: 9)
    @State   var isFullyReady: Bool =  false
    @State   var timer: Timer? = nil
    
    var body: some View{
        ScrollView{
            VStack{
                if !isReady && !isFullyReady{
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TabView(selection: $currentIndex){
                        ForEach(caraDeets.indices, id: \.self) {i in
                            let anime = caraDeets[i]
                            let malId = anime["mal_id"] as? Int ?? 0
                            caraCard(anime: anime, malId: malId)
                                .tag(i)
                                .padding(10)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 275)
                    .clipped()
                    .onAppear {
                        guard timer == nil else {return}
                        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                            guard !caraDeets.isEmpty else {return}
                            withAnimation{
                                currentIndex = (currentIndex + 1) % caraDeets.count
                            }
                        }
                    }
                    
                    VStack(alignment: .leading){
                        homeTab(data: seasonalDeets, dataPage: $currentSeasonalPage, Title: "Now Airing", fetch: getSeasonal)
                        homeTab(data: topDeets, dataPage: $currentTopPage, Title: "Most Popular", fetch: getTop)
                                                
                        ForEach(genres.indices, id: \.self) { g in
                            if (!genreDeets[g].isEmpty) {
                                homeTab(data: genreDeets[g], dataPage: $currentGenrePage[g], Title: genres[g].name, fetch: {page in await getGenre(genreIndex: g, page: page)})
                            }
                        }
                        
                        homeTab(data: upcomingDeets, dataPage: $upcomingPage, Title: "Coming Soon", fetch: getUpcoming)

                    }
                }

            }
            .padding()
            .task {
                guard !isFullyReady else {return}
                await loadInit()
                
                if Task.isCancelled { return }
                isFullyReady = true
            }
        }
        .sheet(isPresented: $showDetails){
                NavigationStack{
                    AnimeView(id: selectedId)
                }
            }
    }
}

