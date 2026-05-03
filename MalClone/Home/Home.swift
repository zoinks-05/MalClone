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
    @State private var banners: [Int: String] = [:]
    @State private var currentIndex = 0
    @State private var showDetails: Bool = false
    @State private var selectedId: Int = 0
    @State private var isReady: Bool = false
    @State private var currentSeasonalPage = 1
    
    var body: some View{
        ScrollView{
            VStack{
                if !isReady {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TabView(selection: $currentIndex){
                        ForEach(caraDeets.indices, id: \.self) {i in
                            let anime = caraDeets[i]
                            let malId = anime["mal_id"] as? Int ?? 0
                            caraCard(anime: anime, malId: malId)
                                .tag(i)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    
                    VStack(alignment: .leading){
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text("Now Airing")
                                    .font(.title.bold())
                                Spacer()
                            }
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack(spacing: 12){
                                    ForEach(seasonalDeets.indices, id: \.self) { i in
                                        let anime = seasonalDeets[i]
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
                                            if i == seasonalDeets.count - 1 {
                                                Task { await getSeasonal(page: currentSeasonalPage + 1)}
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

            }
            .padding()
            .sheet(isPresented: $showDetails){
                NavigationStack{
                    AnimeView(id: selectedId)
                }
            }
            .task {
                await loadInit()
            }
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
            .clipped()
            .overlay(
                LinearGradient(colors: [Color.clear, Color.black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
            )
            .onTapGesture {
                selectedId = malId
                showDetails = true
            }
            .cornerRadius(30)
        )
    }
    
    func loadInit() async {
        do {
            let json = try await APIService.shared.fetchCarasoulAnime()
            caraDeets = json["data"] as? [[String: Any]] ?? []
            await getSeasonal()
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
        print(banners)
        print("Yes")
    }
    
    func imageURL(_ anime: [String: Any]) -> URL? {
        let images = anime["images"] as? [String: Any]
        let jpg    = images?["jpg"]  as? [String: Any]
        return URL(string: jpg?["image_url"] as? String ?? "")
    }
    
    func getSeasonal(page: Int = 1) async {
        do {
            let json_seasonal =  try await APIService.shared.fetchSeasonalAnime(page: page)
            if page == 1 {
                seasonalDeets = json_seasonal["data"] as? [[String: Any]] ?? []
            } else {
                seasonalDeets.append(contentsOf: json_seasonal["data"] as? [[String: Any]] ?? [])
            }
        } catch {
            print(error.localizedDescription)
        }
    }

}
