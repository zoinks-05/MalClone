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
//    @State var showReviewSheet = false reference
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .foregroundStyle(.secondary)
                .font(.system(size: 75))
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
            List {
                Section("Username:") {
                    HStack {
                        Text(username)
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                    }
                }
                
                Section("Bio:") {
                    HStack {
                        if bio.isEmpty {
                            Text("Add Your Bio!")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20))
                        }
                        
                        else {
                            Text(bio)
                            Spacer()
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20))
                        }
                    }
                }
                
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

#Preview {
    ProfileView()
}
