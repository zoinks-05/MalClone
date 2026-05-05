//
//  AnimeDetails.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 1/5/2026.
//

import SwiftUI

struct AnimeView: View{
    @State  var isLoading: Bool = false
    @State  var anime: [String: Any] = [:]
    @State  var characters: [[String:Any]] = []
    @State  var bannerURL: String? = nil
    @State  var hasEntered = false
    @State  var showMoreInfo = false
    @State  var showAddAlert =  false
    @State  var showRemovalAlert =  false
    @State  var synopsisExpanded = false
    @State  var backgroundExpanded = false
    @State  var draftEps = 0
    @State  var draftStatus = WatchStatus.planToWatch
    @State  var draftScore = 0
    @State  var selectedTab = 0
    @State var showReviewSheet = false
    @State var draftReviewTitle = ""
    @State var draftReviewBody = ""
    @State var draftIsSpoiler = false
    let id: Int
    
    var body: some View{
        VStack(spacing: 0) {
            if anime.isEmpty {
                ProgressView()
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                header()
                
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
                        
                        if !characters.isEmpty{
                            charCard()
                        }
                        
                        let related = anime["relations"] as? [[String: Any]] ?? []
                        if !related.isEmpty{
                            relationCard(related: related)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                } else {
                    let reviews = LocalStore.shared.getReviews(id: id)
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

                    
                    if reviews.isEmpty {
                        ContentUnavailableView("No Reviews", systemImage: "pencil.slash", description: Text("You have not reviewed this anime yet"))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            ForEach(reviews) { review in
                                VStack(alignment: .leading){
                                    HStack {
                                        Text(review.title)
                                        Spacer()
                                        if review.isSpoiler{
                                            Text("Spoiler")
                                        }
                                    }
                                    Text(review.body)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task{
            await fetchAll()
            hasEntered = LocalStore.shared.isEntered(id: id) ?? false
        }
        
    }
    
    func reviewPublishView() -> some View{
        NavigationStack{
           Form{
               Section("Title"){
                   TextField("Your Title", text: $draftReviewTitle)
               }
               Section("Body"){
                   TextField("Main content...", text: $draftReviewBody)
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
                       showReviewSheet = false
                   }
                   .disabled(draftReviewTitle.isEmpty || draftReviewBody.isEmpty)
               }
               
           }
       }
    }
    
    
}
