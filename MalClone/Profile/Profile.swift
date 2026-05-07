//
//  Profile.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

// Fake Profile Image
// User Model
// Bio
// Picker to swap besides watchlist and reviews
// Watchlist should be able to remove/edit using the addWatchList view as reference and structure in extension_animedetails
// Review should be able to edit reviews using the reviewPublishView() as reference and structure in AnimeDetails
// Use sheets and showreviewsheet = false

struct ProfileView: View {
    let username = LocalStore.shared.user.name
    let bio = LocalStore.shared.user.bio
    @State var newUsername = ""
    @State var newBio = ""
    @State var showEditProfileSheet = false

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
                        editProfile(username: username, bio: bio)
                    }
                    
//                    NavigationLink {
//                        editProfile()
//                    } label: {
//                        Text("Edit Profile")
//                        Image(systemName: "pencil.circle.fill")
//                            .font(.system(size: 20))
//                    }
                    
                    Section("Your WatchList") {
                        Text("See Your WatchList Placeholder")
                    }
                    
                    Section("Your Reviews") {
                        Text("See Your Reviews Placeholder")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
