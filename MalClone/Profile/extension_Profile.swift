//
//  extension_Profile.swift
//  MalClone
//
//  Created by Brian Tran on 7/5/2026.
//

import SwiftUI

extension ProfileView {
    func editProfile(username: String, bio: String) -> some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 75))
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                
                List {
                    Section("Enter New Username:") {
                        TextField(username, text: $newUsername)
                    }
                    
                    Section("Enter New Bio") {
                        TextField(bio, text: $newBio)
                    }
                }
                    Button("Save"){
                        LocalStore.shared.updateProfile(name: newUsername, bio: newBio)
                        showEditProfileSheet = false
                    }
                    .disabled(newUsername.isEmpty && newBio.isEmpty)
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                
                    .onAppear {
                        if !username.isEmpty || !bio.isEmpty{
                            newUsername = username
                            newBio = bio
                        }
                    }
            }
        }
    }
    
    func ReviewView() -> some View{
        let username = LocalStore.shared.user.name
        let score = LocalStore.shared.getWatchlist(id: id)?.score
//        return VStack{
//            .sheet(isPresented: $showReviewSheet){
//                reviewPublishView()
//            }
//            .padding(.bottom, 10)
//            .disabled(!hasEntered)
        return VStack {
            if reviews.isEmpty {
                ContentUnavailableView("No Reviews", systemImage: "pencil.slash", description: Text("You have not reviewed any anime yet"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    ForEach(reviews) { review in
                        ReviewCard(review: review, username: username, score: score!)
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
        .frame(maxWidth:350, maxHeight: .infinity)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
