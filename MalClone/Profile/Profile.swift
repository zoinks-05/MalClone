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
    @State var reviews: [Review] = []
    @State var watchlist = LocalStore.shared.user.watchlist
    @State var anime: [String: Any] = [:]
    @State var selectedAnime: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle")
                    .foregroundStyle(.secondary)
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
                            .foregroundStyle(.black)
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
