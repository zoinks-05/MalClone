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
    @State  var showRemoveReview = false
    @State  var draftEps = 0
    @State  var draftStatus = WatchStatus.planToWatch
    @State  var draftScore = 0
    @State  var selectedTab = 0
    @State var showReviewSheet = false
    @State var showSpoiler = false
    @State var draftReviewTitle = ""
    @State var draftReviewBody = ""
    @State var draftIsSpoiler = false
    @State var reviews: [Review] = []
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
                    ReviewView()
                        .onAppear{
                            reviews = LocalStore.shared.getReviews(id: id)
                        }

                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task{
            await fetchAll()
            hasEntered = LocalStore.shared.isEntered(id: id)
        }
        
    }
    
    
}
