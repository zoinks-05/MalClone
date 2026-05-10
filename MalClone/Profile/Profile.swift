//
//  Profile.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

struct ProfileView: View {
    @State var username = LocalStore.shared.user.name
    @State var bio = LocalStore.shared.user.bio
    @State var newUsername = ""
    @State var newBio = ""
    @State var showEditProfileSheet = false
    @State var selectedTab = 0
    @State var showReviewSheet = false
    @State var showRemovalAlert = false
    @State var reviewTitle = ""
    @State var reviewBody = ""
    @State var isSpoiler = false
    @State var newReviewTitle = ""
    @State var newReviewBody = ""
    @State var newIsSpoiler = false
    @State var watchedEps = 0
    @State var watchStatus = WatchStatus.planToWatch
    @State var animeScore = 0
    @State var newWatchedEps = 0
    @State var newAnimeScore = 0
    @State var newWatchStatus = WatchStatus.planToWatch
    @State var hasEntered = false
    @State var showAddAlert = false
    @State var reviews: [Review] = []
    @State var watchlist = LocalStore.shared.user.watchlist
    @State var anime: [String: Any] = [:]
    @State var selectedAnime: WatchListEntry?
    @State var editAnime: WatchListEntry?
    @State var deleteThisAnime: WatchListEntry?
    @State var selectedReview: Review?
    @State var deleteThisReview: Review?
    @State var id = 0
    @State var isLoadingEpisode = false
    @State var totalEpisodes = 0

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 75))
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                List {
                    Section("Username:") {
                        Text(username)
                    }
                    
                    Section("Bio:") {
                        if bio.isEmpty {
                            Text(username + " has not added a bio.")
                                .foregroundStyle(.secondary)
                        }
                            
                        else {
                            Text(bio)
                        }
                    }
                    
                    Button {
                        showEditProfileSheet = true
                    } label: {
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .sheet(isPresented: $showEditProfileSheet){
                        editProfileView(username: username, bio: bio)
                    }
                    
                    Section() {
                        Picker("", selection: $selectedTab){
                            Text("Your Watchlist").tag(0)
                            Text("Your Reviews").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(12)
                        
                        if selectedTab == 0 {
                            WatchListView()
                        }
                        
                        else {
                            ReviewView()
                                .onAppear{
                                    reviews = LocalStore.shared.user.reviews
                                }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
