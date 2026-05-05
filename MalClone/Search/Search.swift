//
//  Search.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

struct AnimeID: Identifiable, Equatable {
    let id: Int
}

struct SearchView: View{
    @State var query = ""
    @State var sortType = "asc"
    @State var orderBy = OrderBy.popularity
    @State var res: [[String: Any]] = []
    @State var pageData: [String: Any] = [:]
    @State var isLoading = false
    @State var currentPage = 1
    @State var isFetchingMore = false
    @State var selectedId: AnimeID? = nil

    var body: some View{
        VStack (spacing: 0) {
            HStack{
                HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search anime...", text: $query)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            Task { await fetchQuery() }
                        }
                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                }
                .padding(12)
                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 100))
                
                Button{
                    sortType = sortType == "asc" ? "desc" : "asc"
                    Task { await fetchQuery() }
                } label: {
                    Image(systemName: sortType == "asc" ? "arrow.up.circle" : "arrow.down.circle")
                        .font(.system(size: 28))
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                }
                
                Menu{
                    ForEach(OrderBy.allCases, id: \.self) { opt in
                        Button{
                            orderBy = opt
                            Task { await fetchQuery() }
                        } label: {
                            Label(
                                opt.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                                systemImage: orderBy == opt ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .font(.system(size: 28))
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                }
                
                
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
            } else if !res.isEmpty {
                CardLogic
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
            } else{
                Spacer()
            }
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}
