//
//  Profile.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

struct ProfileView: View {
//    @State var showReviewSheet = false reference
    var body: some View {
        Text("Works")
        // Fake Profile Image
        // User Model
        // Bio
        // Picker to swap besides watchlist and reviews
        // Watchlist should be able to remove/edit using the addWatchList view as reference and structure in extension_animedetails
        // Review should be able to edit reviews using the reviewPublishView() as reference and structure in AnimeDetails
        // Use sheets and showreviewsheet = false
    }
}

//func addToWatchListView() -> some View{ reference
//
//    let totalEps = anime["episodes"] as? Int ?? 0
//    
//    return NavigationStack{
//        Form{
//            Section("Episodes"){
//                Text("Watched: \(draftEps) / \(totalEps)")
//                Slider(
//                    value: Binding(get: {Double(draftEps)}, set: {draftEps = Int($0)}),
//                    in:0...Double(max(0,totalEps)),
//                    step: 1
//                )
//                .tint(.purple)
//            }
//            Section("Score"){
//                Text("Score: \(draftScore)")
//                Slider(
//                    value: Binding(get: {Double(draftScore)}, set: {draftScore = Int($0)}),
//                    in:0...10,
//                    step: 1
//                )
//                .tint(.purple)
//            }
//            Section("Status"){
//                Picker("Status", selection: $draftStatus){
//                    ForEach(WatchStatus.allCases, id: \.self){
//                        Text($0.rawValue)
//                    }
//                }
//            }
//            .pickerStyle(.segmented)
//        }
//        .navigationTitle(hasEntered ? "Edit entry" : "Add to Watchlist")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar{
//            ToolbarItem(placement: .cancellationAction){
//                Button("Cancel") { showAddAlert = false}
//            }
//            ToolbarItem(placement: .confirmationAction){
//                Button(hasEntered ? "Update" : "Add"){
//                    let title = anime["title"] as? String ?? ""
//                    if hasEntered{
//                        LocalStore.shared.updateWatchList(id: id, status: draftStatus, score: draftScore, epsWatched: draftEps)
//                    } else{
//                        LocalStore.shared.addToWatchList(id: id, title: title, status: draftStatus, score: draftScore, epsWatched: draftEps)
//                    }
//                    hasEntered = true
//                    showAddAlert = false
//                }
//            }
//            
//        }
//    }
//}

//func reviewPublishView() -> some View{ reference
//    NavigationStack{
//       Form{
//           Section("Title"){
//               TextField("Your Title", text: $draftReviewTitle)
//           }
//           Section("Body"){
//               TextField("Main content...", text: $draftReviewBody)
//                   .lineLimit(4...10)
//           }
//           Section("Spoiler Mode"){
//               Toggle("Contains Spoilers", isOn: $draftIsSpoiler)
//                   .tint(.purple)
//           }
//       }
//       .navigationTitle("Write a Review")
//       .navigationBarTitleDisplayMode(.inline)
//       .toolbar{
//           ToolbarItem(placement: .cancellationAction){
//               Button("Cancel") { showReviewSheet = false}
//           }
//           ToolbarItem(placement: .confirmationAction){
//               Button("Publish"){
//                   let existingId = LocalStore.shared.getReviews(id:id).first?.id
//                   
//                   if let existingId{
//                       LocalStore.shared.updateReview(id: existingId, title: draftReviewTitle, body: draftReviewBody, isSpoiler: draftIsSpoiler)
//                   } else {
//                       LocalStore.shared.addReview(Id: id, title: draftReviewTitle, body: draftReviewBody, isSpoiler: draftIsSpoiler)
//                   }
//                   showReviewSheet = false
//               }
//               .disabled(draftReviewTitle.isEmpty || draftReviewBody.isEmpty)
//           }
//           
//       }
//   }
//}
