//
//  services_Search.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 4/5/2026.
//

import Foundation

extension SearchView{
    // Fetch query logic
    func fetchQuery() async {
        // clean up query and make sure its not empty
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
    
    // Get the next page
    func nextPage() async {
        // Make sure there is even another page
        guard !isFetchingMore, pageData["has_next_page"] as? Bool == true else { return }
        isFetchingMore = true
        currentPage += 1
        do {
            let json = try await APIService.shared.searchAnimePaged(
                query: query,
                page: currentPage,
                orderBy: orderBy,
                sort: sortType
            )
            let newItems = json["data"] as? [[String: Any]] ?? []
            pageData = json["pagination"] as? [String: Any] ?? [:]
            res.append(contentsOf: newItems)
        } catch {
            print(error.localizedDescription)
        }
        isFetchingMore = false
    }

}
