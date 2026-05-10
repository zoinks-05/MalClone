//
//  extension_Profile.swift
//  MalClone
//
//  Created by Brian Tran on 7/5/2026.
//

import SwiftUI

extension ProfileView {
    func editProfileView(username: String, bio: String) -> some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 75))
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                
                List {
                    Section("Enter New Username:") {
                        TextField("Enter Username", text: $newUsername)
                    }
                    
                    Section("Enter New Bio") {
                        TextField("Enter Bio", text: $newBio)
                    }
                }
                    Button("Save") {
                        LocalStore.shared.updateProfile(name: newUsername, bio: newBio)
                        self.username = newUsername
                        self.bio = newBio
                        showEditProfileSheet = false
                    }
                    .disabled(newUsername.isEmpty && newBio.isEmpty)
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                
                    .onAppear {
                        newUsername = username
                        newBio = bio
                    }
            }
        }
    }
    
    func ReviewView() -> some View{
        return VStack {
            if reviews.isEmpty {
                ContentUnavailableView("No Reviews", systemImage: "pencil.slash", description: Text("You have not reviewed any anime yet"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    ForEach(reviews) { review in
                        let score = watchlist.first(where: {$0.id == review.animeId})?.score
                        ReviewCard(review: review, username: username, score: score ?? 0)
                    }
                }
            }
        }
    }
    
    func ReviewCard(review: Review, username: String, score: Int) -> some View{
        return VStack(alignment: .leading) {
            Text(review.title)
                .font(.title2.weight(.semibold))
            HStack{
                Text(username)
                Spacer()
                Text("\(score)/10")
            }
            Divider()
            HStack{
                Text(review.body)
                Spacer()
                VStack{
                    Button{
                        showReviewSheet = true
                        selectedReview = review
                    } label: {
                        Image(systemName: "pencil.circle")
                            .font(.system(size: 25))
                    }
                    .sheet(item: $selectedReview) { review in
                        editReviewView(review: review, reviewTitle: review.title, reviewBody: review.body)
                    }
                    .padding()
                    Button{
                        LocalStore.shared.deleteReview(id: review.id)
                        reviews = LocalStore.shared.user.reviews
                    } label: {
                        Image(systemName: "multiply.circle")
                            .font(.system(size: 25))
                            .foregroundColor(.red)
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    func editReviewView(review: Review ,reviewTitle: String, reviewBody: String) -> some View{
        NavigationStack{
           Form{
               Section("Title"){
                   TextField(reviewTitle, text: $newReviewTitle)
               }
               Section("Body"){
                   TextField(reviewBody, text: $newReviewBody, axis: .vertical)
                       .lineLimit(4...10)
               }
               Section("Spoiler Mode"){
                   Toggle("Contains Spoilers", isOn: $newIsSpoiler)
                       .tint(.purple)
               }
           }
           .navigationTitle("Edit Your Review")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar{
               ToolbarItem(placement: .cancellationAction){
                   Button("Cancel") {
                       selectedReview = nil
                   }
               }
               ToolbarItem(placement: .confirmationAction){
                   Button("Save"){
                       LocalStore.shared.updateReview(id: review.id, title: newReviewTitle, body: newReviewBody, isSpoiler: newIsSpoiler)
                       reviews = LocalStore.shared.user.reviews
                       selectedReview = nil
                   }
                   .disabled(newReviewTitle.isEmpty || newReviewBody.isEmpty)
               }
               
           }
           .onAppear {
                   newReviewTitle = reviewTitle
                   newReviewBody = reviewBody
           }
       }
    }
    
    func WatchListView() -> some View{
        return VStack {
            if watchlist.isEmpty {
                ContentUnavailableView("No Anime", systemImage: "pencil.slash", description: Text("You have no anime in your watchlist"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    ForEach(watchlist) { anime in
                        WatchListCard(anime: anime)
                    }
                }
            }
        }
    }
    
    func WatchListCard(anime: WatchListEntry) -> some View {
        return VStack(alignment: .leading) {
            Text(anime.title)
                .font(.title2.weight(.semibold))
            HStack{
                Text(anime.status.rawValue)
                Spacer()
                if let score = anime.score {
                    Text("\(score)/10")
                }
            }
            Divider()
            HStack {
                Text("Episodes Watched: \(anime.epsWatched)")
                Spacer()
                Button {
                    editAnime = anime
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 25))
                }
                .sheet(item: $editAnime) { anime in
                    editWatchListView(animeToEdit: anime)
                }
                .padding()
                
                Button {
                    showRemovalAlert = true
                    deleteThisAnime = anime
                } label: {
                    Image(systemName: "multiply.circle")
                        .font(.system(size: 25))
                        .foregroundColor(.red)
                }
                .alert("Remove from Watchlist?", isPresented: $showRemovalAlert) {
                    Button("Remove", role: .destructive) {
                        if let anime = deleteThisAnime {
                            LocalStore.shared.removeFromWatchList(id: anime.id)
                            showRemovalAlert = false
                        }
                        deleteThisAnime = nil
                        watchlist = LocalStore.shared.user.watchlist
                    }
                    Button("Cancel", role: .cancel) {
                        deleteThisAnime = nil
                    }
                } message: {
                    if let anime = deleteThisAnime {
                        Text("\(anime.title) will be wiped from your account and will not be saved")
                    }
                }
            }
            .padding()
        }
        .onTapGesture {
            selectedAnime = anime
        }
        .sheet(item: $selectedAnime) { anime in
            AnimeView(id: anime.id)
        }
    }
    
    func editWatchListView(animeToEdit: WatchListEntry) -> some View {
        return NavigationStack {
            Form {
                Section("Episodes"){
                    if totalEpisodes > 0 {
                        Text("Watched: \(newWatchedEps) / \(totalEpisodes)")
                        Slider(
                            value: Binding(get: {Double(newWatchedEps)}, set: {newWatchedEps = Int($0)}),
                            in:0...Double(max(0,totalEpisodes)),
                            step: 1
                        )
                        .tint(.purple)
                    } else {
                        Text("Episode Count Unknown")
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Score"){
                    Text("Score: \(newAnimeScore)")
                    Slider(
                        value: Binding(get: {Double(newAnimeScore)}, set: {newAnimeScore = Int($0)}),
                        in:0...10,
                        step: 1
                    )
                    .tint(.purple)
                }
                Section("Status"){
                    Picker("Status", selection: $newWatchStatus){
                        ForEach(WatchStatus.allCases, id: \.self){
                            Text($0.rawValue)
                        }
                    }
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle("Edit entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel") {
                        editAnime = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("Update") {
                        LocalStore.shared.updateWatchList(id: animeToEdit.id, status: newWatchStatus, score: newAnimeScore, epsWatched: newWatchedEps)
                        watchlist = LocalStore.shared.user.watchlist
                        editAnime = nil
                    }
                }
                
            }
            .task {
                newWatchedEps = animeToEdit.epsWatched
                newAnimeScore = animeToEdit.score ?? 0
                newWatchStatus = animeToEdit.status
                await fetchTotalEpisodes(id: animeToEdit.id)
            }
        }
    }
}
