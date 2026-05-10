//
//  Home.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

struct HomeView: View{
    @State private var caraDeets: [[String: Any]] = []
    @State private var seasonalDeets: [[String: Any]] = []
    @State private var topDeets: [[String: Any]] = []
    @State private var upcomingDeets: [[String: Any]] = []
    @State private var banners: [Int: String] = [:]
    @State private var currentIndex = 0
    @State private var showDetails: Bool = false
    @State private var selectedId: Int = 0
    @State private var isReady: Bool = false
    @State private var currentSeasonalPage = 1
    @State private var currentTopPage = 1
    @State private var upcomingPage = 1
    @State private var genres: [(id: Int, name: String)] = [ (1, "Action"),
                                                   (2, "Adventure"),
                                                   (4, "Comedy"),
                                                   (8, "Drama"),
                                                   (10, "Fantasy"),
                                                   (14, "Horror"),
                                                   (7, "Mystery"),
                                                   (22, "Romance"),
                                                   (24, "Sci-Fi")]
    @State private var genreDeets: [[[String: Any]]] = Array(repeating: [], count: 9)
    @State private var currentGenrePage = Array(repeating: 1, count: 9)
    @State private var isFullyReady: Bool =  false
    
    @State private var timer: Timer? = nil
    
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
                                VStack(alignment: .leading){
                                    HStack{
                                        Text(genres[g].name)
                                            .font(.title.bold())
                                        Spacer()
                                    }
                                    ScrollView(.horizontal, showsIndicators: false){
                                        HStack(spacing: 12){
                                            ForEach(genreDeets[g].indices, id: \.self) { i in
                                                let anime = genreDeets[g][i]
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
                                                        showDetails = true
                                                    }
                                                }
                                                .onAppear{
                                                    if i == genreDeets[g].count - 1 {
                                                        currentGenrePage[g] += 1
                                                        Task { await getGenre(genreIndex: g, page: currentGenrePage[g])}
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Divider()
                                        .padding()
                                }
                            }
                        }
                        
                        homeTab(data: upcomingDeets, dataPage: $upcomingPage, Title: "Coming Soon", fetch: getUpcoming)

                    }
                }

            }
            .padding()
            .sheet(isPresented: $showDetails){
                NavigationStack{
                    AnimeView(id: selectedId)
                }
            }
            .task {
                guard !isFullyReady else {return}
                await loadInit()
                isFullyReady = true
            }
        }
    }
    
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
                                showDetails = true
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
    
    func caraCard(anime: [String:Any], malId: Int) -> some View{
        VStack(alignment: .leading){
            Spacer()
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
            AsyncImage(url: URL(string: banners[malId] ?? "")){ s in
                switch s {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Color.gray.opacity(0.2)
                }
            }
            .id(malId)
            .overlay(
                LinearGradient(colors: [Color.clear, Color.black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
            )
            .onTapGesture {
                selectedId = malId
                showDetails = true
            }
        )
    }
    
    func loadInit() async {
        do {
            let json = try await APIService.shared.fetchCarasoulAnime()
            caraDeets = json["data"] as? [[String: Any]] ?? []
            await getSeasonal()
            await getTop()
            for g in 0..<genres.count {
                await getGenre(genreIndex: g)
            }
            await getUpcoming()
            await getBanner()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getBanner() async {
        for anime in caraDeets{
            guard let malid = anime["mal_id"] as? Int else {continue}
            let res = try? await APIService.shared.fetchAniListImages(malId: malid)
            let media = (res?["data"] as? [String: Any])?["Media"] as? [String: Any]
            if let banner = media?["bannerImage"] as? String{
                banners[malid] = banner
            }
        }
        isReady = true
    }
        
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
