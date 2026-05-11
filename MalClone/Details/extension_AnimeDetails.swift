//
//  extension_AnimeDetails.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 4/5/2026.
//

import SwiftUI

extension AnimeView{
    
    // Review view
    func ReviewView() -> some View{
        let username = LocalStore.shared.user.name
        let score = LocalStore.shared.getWatchlist(id: id)?.score
        return VStack{
            Button {
                showReviewSheet = true
            } label: {
                Text("Create a review")
                    .frame(maxWidth: 350)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }
            .sheet(isPresented: $showReviewSheet){
                reviewPublishView()
            }
            .padding(.bottom, 10)
            .disabled(!hasEntered)
            
            // Check if reviews are empty and deal with it accordingly
            if reviews.isEmpty {
                ContentUnavailableView("No Reviews", systemImage: "pencil.slash", description: Text("You have not reviewed this anime yet"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    ForEach(reviews) { review in
                        ReviewCard(review: review, username: username, score: score ?? 0)
                    }
                }
            }
        }
    }

    // Review card
    func ReviewCard(review: Review, username: String, score: Int) -> some View{
        VStack(alignment: .leading){
            Text(review.title)
                .font(.title2.weight(.semibold))
            HStack{
                Text(username)
                Spacer()
                Text("\(score)/10")
                if review.isSpoiler{
                    Button{
                        showSpoiler.toggle()
                    } label: {
                        Image(systemName: !showSpoiler ? "eye.slash": "eye")
                            .foregroundColor(.red)
                    }
                }
            }
            Divider()
            HStack{
                Text(review.body)
                    .blur(radius: review.isSpoiler && !showSpoiler ? 8 : 0)
                    .animation(.easeInOut, value: showSpoiler)
                if hasEntered{
                    Spacer()
                    VStack{
                        Button{
                          showReviewSheet = true
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 25))
                        }
                        .padding()
                        Button{
                            if let reviewId = reviews.first?.id{
                                LocalStore.shared.deleteReview(id: reviewId)
                                reviews = LocalStore.shared.getReviews(id: id)
                            }
                        } label: {
                            Image(systemName: "multiply.circle")
                                .font(.system(size: 25))
                                .foregroundColor(.red)
                        }
                        .padding()

                    }
                }
            }
        }
        .frame(maxWidth:350, maxHeight: .infinity)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // View for publishing review
    func reviewPublishView() -> some View{
        NavigationStack{
           Form{
               Section("Title"){
                   TextField("Your Title", text: $draftReviewTitle)
               }
               Section("Body"){
                   TextField("Main content...", text: $draftReviewBody, axis: .vertical)
                       .lineLimit(4...10)
               }
               Section("Spoiler Mode"){
                   Toggle("Contains Spoilers", isOn: $draftIsSpoiler)
                       .tint(.purple)
               }
           }
           .navigationTitle("Write a Review")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar{
               ToolbarItem(placement: .cancellationAction){
                   Button("Cancel") { showReviewSheet = false}
               }
               ToolbarItem(placement: .confirmationAction){
                   Button("Publish"){
                       let existingId = LocalStore.shared.getReviews(id:id).first?.id
                       
                       if let existingId{
                           LocalStore.shared.updateReview(id: existingId, title: draftReviewTitle, body: draftReviewBody, isSpoiler: draftIsSpoiler)
                       } else {
                           LocalStore.shared.addReview(Id: id, title: draftReviewTitle, body: draftReviewBody, isSpoiler: draftIsSpoiler)
                       }
                       reviews = LocalStore.shared.getReviews(id: id)
                       showReviewSheet = false
                   }
                   .disabled(draftReviewTitle.isEmpty || draftReviewBody.isEmpty)
               }
               
           }
       }
    }
    
    // Header view
    func header() -> some View{
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
    
    // Card for related anime
    func relatedCard(item: [String: Any], relation: String) -> some View{
        VStack(alignment: .leading) {
                Text(item["name"] as? String ?? "N/A")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(item["type"] as? String ?? "N/A")
                    .font(.caption2)
                    .foregroundStyle(.purple)
                Text(relation)
                    .font(.caption2)
                    .foregroundStyle(.purple)
            }
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .frame(maxWidth:100, minHeight: 50)
            .cornerRadius(12)
    }
    
    // Main card view
    func MainCard(label: String, value: String, condition: Binding<Bool> ) -> some View{
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // View for adding to watchlist
    func addToWatchListView() -> some View{
        
        let totalEps = anime["episodes"] as? Int ?? 0
        
        return NavigationStack{
            Form{
                Section("Episodes"){
                    if totalEps > 0 {
                        Text("Watched: \(draftEps) / \(totalEps)")
                        Slider(
                            value: Binding(get: {Double(draftEps)},
                                           set: {
                                               // adjust watchstatus depending on eps watched
                                               draftEps = Int($0)
                                               if draftEps > 0 && draftStatus == .planToWatch{
                                                   draftStatus = .watching
                                               }
                                               if draftEps == totalEps && totalEps > 0 {
                                                   draftStatus = .completed
                                               }
                                           }),
                            in:0...Double(max(0,totalEps)),
                            step: 1
                        )
                        .tint(.purple)
                    } else {
                        Text("Episode Count Unknown")
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Score"){
                    Text("Score: \(draftScore)")
                    Slider(
                        value: Binding(get: {Double(draftScore)}, set: {
                            draftScore = Int($0)
                            // change watchstatus depending on score
                            if draftScore > 0 && draftStatus == .planToWatch {
                                draftStatus = .watching
                            }
                        }),
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
    
    // View for stats for an anime
    func detailView() -> some View{
        VStack{
            Text(anime["title"] as? String ?? "Unknown Title")
                .font(.title.bold())
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
    
    // Styling for stats as row
    func tagRow(label: String, tags: [String]) -> some View{
        VStack(alignment: .leading, spacing: 2){
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    //Styling for stats
    func stat(label: String, value: String) -> some View{
        VStack(alignment: .leading, spacing: 2){
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // Card for character
    func charCard() -> some View{
        VStack(alignment: .leading){
            Text("Characters")
                .font(.caption)
                .foregroundStyle(.primary)
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing:12){
                    ForEach(characters.indices, id: \.self){ i in
                        let entry = characters[i]
                        let person = entry["character"] as? [String: Any] ?? [:]
                        let name = person["name"] as? String ?? "N/A"
                        let role = entry["role"] as? String ?? "N/A"
                        VStack(alignment: .leading) {
                            AsyncImage(url: imageURL(person)){ p in
                                switch p {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    Color.secondary.opacity(0.2)
                                }
                            }
                            .frame(width: 80, height: 130)
                            .cornerRadius(12)

                            Text(name)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(2)

                            Text(role)
                                .font(.caption)
                                .foregroundStyle(.purple)
                        }
                    }
                    .frame(width: 100, height: 180)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(12)
    }
    
    // Card for related animes
    func relationCard(related: [[String: Any]]) -> some View{
        VStack(alignment: .leading){
            Text("Related")
                .font(.caption)
                .foregroundStyle(.primary)
            
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
        .background(Color(.secondarySystemBackground))
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(12)

    }


}
