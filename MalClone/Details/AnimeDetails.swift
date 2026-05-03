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
    @State private var hasEntered = false
    @State private var showMoreInfo = false
    @State private var showAddAlert =  false
    @State private var showRemovalAlert =  false
    @State private var synopsisExpanded = false
    @State private var backgroundExpanded = false
    @State private var draftEps = 0
    @State private var draftStatus = WatchStatus.planToWatch
    @State private var draftScore = 0
    @State private var selectedTab = 0
    let id: Int
    
    var body: some View{
        VStack(spacing: 0) {
            if anime.isEmpty {
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
                        HStack(spacing: 10){
                            Text(anime["title"] as? String ?? "Unknown Title")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button{
                                showAddAlert = true
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 25))
                                    .foregroundColor(.purple)
                            }
                        }
                        .sheet(isPresented: $showAddAlert){
                            addToWatchListView()
                        }
                        HStack(spacing: 10){
                            Text(String(format: "%.2f", anime["score"] as? Double ?? 0.0))
                                .font(.caption)
                                .foregroundColor(.white)
                            Text((anime["studios"] as? [[String: Any]])?.first?["name"] as? String ?? "Unknown Studio")
                                .font(.caption)
                                .foregroundColor(.white)
                            Button{
                                showMoreInfo = true
                            } label: {
                                Text("More Info")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            }
                            
                            Spacer()
                            
                            if hasEntered{
                                Button{
                                    showRemovalAlert = true
                                } label: {
                                    Image(systemName: "multiply.circle")
                                        .font(.system(size: 25))
                                        .foregroundColor(.red)
                                }

                            }
                        }
                        .alert("Remove from Watchlist?", isPresented: $showRemovalAlert){
                            Button("Remove", role: .destructive){
                                LocalStore.shared.removeFromWatchList(id: id)
                                hasEntered = false
                                showRemovalAlert = false
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("\(anime["title"] as? String ?? "This anime") will be wiped from your account and will not be saved")
                        }
                        .sheet(isPresented: $showMoreInfo) {
                            detailView()
                                .presentationDetents([.medium, .large])
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
            Picker("", selection: $selectedTab){
                Text("Main").tag(0)
                Text("Reviews").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(12)
            
            if selectedTab == 0 {
                ScrollView{
                    MainCard(label: "Synopsis", value: anime["synopsis"] as? String ?? "N/A", condition: $synopsisExpanded)
                    MainCard(label: "Background", value: anime["background"] as? String ?? "N/A", condition: $backgroundExpanded)
                    let related = anime["relations"] as? [[String: Any]] ?? []
                    if !related.isEmpty{
                        VStack(alignment: .leading){
                            Text("Related")
                                .font(.caption)
                                .foregroundStyle(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack(spacing:12){
                                    ForEach(related.indices, id: \.self){ i in
                                        let rel = related[i]
                                        let relation = rel["relation"] as? String ?? ""
                                        let entries = rel["entry"] as? [[String: Any]] ?? []
                                        
                                        ForEach(entries.indices, id: \.self){ j in
                                            let item = entries[j]
                                            if (item["type"] as? String ?? "") == "anime"{
                                                NavigationLink {
                                                    AnimeView(id: item["mal_id"] as? Int ?? 0)
                                                } label: {
                                                    relatedCard(item: item, relation: relation)
                                                }
                                            } else {
                                                relatedCard(item: item, relation: relation)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(10)
                        .background(.white.opacity(0.07))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task{
            await fetchAll()
            hasEntered = LocalStore.shared.isEntered(id: id) ?? false
        }
        
    }
    
    func relatedCard(item: [String: Any], relation: String) -> some View{
        VStack(alignment: .leading) {
                Text(item["name"] as? String ?? "N/A")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(item["type"] as? String ?? "N/A")
                    .font(.caption2)
                    .foregroundStyle(.purple)
                Text(relation)
                    .font(.caption2)
                    .foregroundStyle(.purple)
            }
            .padding(10)
            .background(.white.opacity(0.07))
            .frame(maxWidth:100, minHeight: 50)
            .cornerRadius(12)
    }
    
    func MainCard(label: String, value: String, condition: Binding<Bool> ) -> some View{
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(condition.wrappedValue ? nil : 3)
            Button{
                condition.wrappedValue.toggle()
            } label:{
                Text(condition.wrappedValue ? "Show Less" : "Show More")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.07))
        .cornerRadius(12)
    }
    
    func addToWatchListView() -> some View{
        
        let totalEps = anime["episodes"] as? Int ?? 0
        
        return NavigationStack{
            Form{
                Section("Episodes"){
                    Text("Watched: \(draftEps) / \(totalEps)")
                    Slider(
                        value: Binding(get: {Double(draftEps)}, set: {draftEps = Int($0)}),
                        in:0...Double(max(0,totalEps)),
                        step: 1
                    )
                    .tint(.purple)
                }
                Section("Score"){
                    Text("Score: \(draftScore)")
                    Slider(
                        value: Binding(get: {Double(draftScore)}, set: {draftScore = Int($0)}),
                        in:0...10,
                        step: 1
                    )
                    .tint(.purple)
                }
                Section("Status"){
                    Picker("Status", selection: $draftStatus){
                        ForEach(WatchStatus.allCases, id: \.self){
                            Text($0.rawValue)
                        }
                    }
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle(hasEntered ? "Edit entry" : "Add to Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel") { showAddAlert = false}
                }
                ToolbarItem(placement: .confirmationAction){
                    Button(hasEntered ? "Update" : "Add"){
                        let title = anime["title"] as? String ?? ""
                        if hasEntered{
                            LocalStore.shared.updateWatchList(id: id, status: draftStatus, score: draftScore, epsWatched: draftEps)
                        } else{
                            LocalStore.shared.addToWatchList(id: id, title: title, status: draftStatus, score: draftScore, epsWatched: draftEps)
                        }
                        hasEntered = true
                        showAddAlert = false
                    }
                }
                
            }
        }
    }
    
    func detailView() -> some View{
        VStack{
            Text(anime["title"] as? String ?? "Unknown Title")
                .font(.title.bold())
                .foregroundColor(.white)
                .padding(.top, 10)
                .padding(.vertical, 10)
            Text("\(anime["title_japanese"] as? String ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.purple)
            
            Divider()
            ScrollView{
                if let studios = anime["studios"] as? [[String: Any]]{
                    tagRow(label: "Studios", tags: studios.compactMap {$0["name"] as? String})
                        .padding(10)
                }
                if let pro = anime["producers"] as? [[String: Any]]{
                    tagRow(label: "Producers", tags: pro.compactMap {$0["name"] as? String})
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())], spacing: 10){
                    stat(label: "Type", value: (anime["type"] as? String ?? "N/A"))
                    stat(label: "Episodes", value: "\(anime["episodes"] as? Int ?? 0)")
                    stat(label: "Status", value: (anime["status"] as? String ?? "N/A"))
                    stat(label: "Score", value: (String(format:"%.2f" ,anime["score"] as? Double ?? 0)))
                    stat(label: "Rank", value: "#\(anime["rank"] as? Int ?? 0)")
                    stat(label: "Popularity", value: "#\(anime["popularity"] as? Int ?? 0)")
                    stat(label: "Season", value: (anime["season"] as? String ?? "N/A"))
                    stat(label: "Year", value: "\(anime["year"] as? Int ?? 0)")
                    
                    
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                
                stat(label: "Rating", value: (anime["rating"] as? String ?? "N/A"))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                
                if let broadcast =  anime["broadcast"] as? [String: Any]{
                    let day = broadcast["day"] as? String ?? "N/A"
                    let t = broadcast["time"] as? String ?? "N/A"
                    let tz = broadcast["timezone"] as? String ?? "N/A"
                    stat(label: "Broadcast", value: "\(day) at \(t) \(tz)")
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
                
                if let genres = anime["genres"] as? [[String: Any]]{
                    tagRow(label: "Genres", tags: genres.compactMap {$0["name"] as? String})
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
                if let themes = anime["themes"] as? [[String: Any]]{
                    tagRow(label: "themes", tags: themes.compactMap {$0["name"] as? String})
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
                if let theme = anime["theme"] as? [String: Any]{
                    if let openings = theme["openings"] as? [String]{
                        tagRow(label: "Openings", tags: openings)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                    }
                    if let endings = theme["endings"] as? [String]{
                        tagRow(label: "Endings", tags: endings)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                    }
                }
            }

        }
    }
    
    func tagRow(label: String, tags: [String]) -> some View{
        VStack(alignment: .leading, spacing: 2){
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
            if tags.count > 4 {
                ForEach(tags, id: \.self){ tag in
                    Text(tag)
                }
            } else {
                HStack(spacing: 6){
                    ForEach(tags, id: \.self){ tag in
                        Text(tag)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.07))
        .cornerRadius(12)
    }
    
    func stat(label: String, value: String) -> some View{
        VStack(alignment: .leading, spacing: 2){
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.07))
        .cornerRadius(12)
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
