//
//  Top.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

struct TopView: View
{
    @State var selectedTab = 0
    @State var isLoading = false
    @State var res: [[String: Any]] = []
    @State var selectedId: AnimeID? = nil
    @State var pageData: [String: Any] = [:]
    @State var currentPage = 1
    @State var isFetchingMore = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Picker("", selection: $selectedTab)
            {
                Text("All").tag(0)
                Text("Anime").tag(1)
                Text("Movie").tag(2)
                Text("OVA").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(12)
            .onChange(of: selectedTab)
            {
                Task { await fetchTop() }
            }
            
            if isLoading
            {
                ProgressView().frame(maxWidth:.infinity, maxHeight: .infinity)
                
            }
            
            else if !res.isEmpty
            {
                CardLogic.frame(maxWidth:.infinity, maxHeight: .infinity)
            }
            
            else
            {
                Spacer()
            }
        }
        .onAppear
        {
            Task { await fetchTop() }
        }
        // remember to change to knr
        // ok me in the past
    }
}
