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
    @State private var query = ""
    @State private var sortType = "asc"
    @State private var orderBy = OrderBy.popularity
    @State private var res: [[String: Any]] = []
    @State private var pageData: [String: Any] = [:]
    @State private var isLoading = false
    @State private var currentPage = 1
    @State private var isFetchingMore = false
    @State private var selectedId: AnimeID? = nil

    var body: some View{
        VStack {
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
            
            if isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else if !res.isEmpty {
                CardLogic
            }
            
            Spacer()
        }
    }
    
    var CardLogic: some View{
        GeometryReader { geo in
            let col = columns(for: geo.size.width)
            let gridItems: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: col)
            
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 16)  {
                    ForEach(res.indices, id: \.self) { i in
                        let anime = res[i]
                        VStack(spacing: 0) {
                            // Cover
                            AsyncImage(url: imageURL(anime)) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    Color.secondary.opacity(0.2)
                                }
                            }
                            .frame(width: 175,  height: 265)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            // Info
                            let isAiring = anime["airing"] as? Bool ?? false
                            VStack(alignment: .leading, spacing: 4) {
                                HStack{
                                    Image(systemName: isAiring ? "dot.radiowaves.left.and.right" : "pause.circle")
                                        .foregroundStyle(isAiring ? .purple : .secondary)
                                    Text(anime["title"] as? String ?? "Unknown")
                                        .font(.headline)
                                }
                                .lineLimit(1)
                                .padding(.top)
                                .padding(.bottom, 2)
                                HStack(spacing: 6){
                                    tags(anime)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                        }
                        .onTapGesture {
                            if let id = anime["mal_id"] as? Int {
                                selectedId = AnimeID(id: id)
                            }
                        }
                        .padding(6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .onAppear {
                            if i ==  res.count - 1{
                                Task { await nextPage()}
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    if isFetchingMore{
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .gridCellColumns(col)
                    }
                }
            }
            .sheet(item: $selectedId) { animeID in
                AnimeView(id: animeID.id)
            }
        }
    }
    
    @ViewBuilder
    func tags(_ anime: [String: Any]) -> some View {
        if let ep = anime["episodes"] as? Int{
            Text("\(ep) eps")
                .lineLimit(1)
                .fixedSize()
                .font(.caption)
                .foregroundStyle(.purple)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.7, green: 0.5, blue: 1).opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
        }

        Text("\(anime["score"] as? Double ?? 0, specifier: "%.2f")")
            .lineLimit(1)
            .fixedSize()
            .font(.caption)
            .foregroundStyle(.purple)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(red: 0.7, green: 0.5, blue: 1).opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
        if let type = anime["type"] as? String{
            Text(type)
                .lineLimit(1)
                .fixedSize()
                .font(.caption)
                .foregroundStyle(.purple)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.7, green: 0.5, blue: 1).opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
        }
    }
    
    private func columns(for w: CGFloat)  -> Int {
        if w >= 1024 { return 6}
        if w >= 768 {return 4}
        return 2
    }
    
    func fetchQuery() async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        currentPage = 1
        do {
            let json = try await APIService.shared.searchAnimePaged(
                query: query,
                page: currentPage,
                orderBy: orderBy,
                sort: sortType
            )
            res = json["data"] as? [[String: Any]] ?? []
            pageData = json["pagination"] as? [String: Any] ?? [:]
            print(res)
            print(pageData)
        } catch {
            print(error.localizedDescription)
        }
        isLoading = false
    }
    
    func nextPage() async {
        guard !isFetchingMore, pageData["has_next_page"] as? Bool == true else { return }
        isFetchingMore = true
        currentPage += 1
        do {
            let json = try await APIService.shared.searchAnimePaged(
                query: query,
                page: currentPage
            )
            let newItems = json["data"] as? [[String: Any]] ?? []
            pageData = json["pagination"] as? [String: Any] ?? [:]
            res.append(contentsOf: newItems)
        } catch {
            print(error.localizedDescription)
        }
        isFetchingMore = false
    }
    
    func imageURL(_ anime: [String: Any]) -> URL? {
        let images = anime["images"] as? [String: Any]
        let jpg    = images?["jpg"]  as? [String: Any]
        return URL(string: jpg?["image_url"] as? String ?? "")
    }
}
