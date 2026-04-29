//
//  DemoView.swift
//  MalClone
//  THIS IS CLAUDE EXAMPLE OF HOW U CAN FETCH AND USE THE RETRNING DATA THIS WILL BE REMOVED LATER ON
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

struct DemoView: View {

    // MARK: - Fetch demo state
    @State private var animeTitle     = ""
    @State private var animeScore     = ""
    @State private var coverURL       = ""
    @State private var bannerURL      = ""
    @State private var fetchLog       = [String]()

    // MARK: - Local store demo state
    @State private var watchlistLog   = [String]()
    @State private var reviewLog      = [String]()

    var body: some View {
        NavigationStack {
            List {

                // ── Fetching ──────────────────────────────────────
                Section("1. Jikan fetch — anime id 1") {
                    Button("Fetch Cowboy Bebop") { Task { await demoFetch() } }
                    if !animeTitle.isEmpty {
                        row("Title",  animeTitle)
                        row("Score",  animeScore)
                    }
                    if !fetchLog.isEmpty {
                        logBlock(fetchLog)
                    }
                }

                Section("2. AniList image fetch — mal id 1") {
                    Button("Fetch Images") { Task { await demoImages() } }
                    if !coverURL.isEmpty  { row("Cover",  coverURL)  }
                    if !bannerURL.isEmpty { row("Banner", bannerURL) }
                }

                // ── Local store ───────────────────────────────────
                Section("3. Watchlist") {
                    Button("Add Cowboy Bebop → Watching, score 9") {
                        demoWatchlist()
                    }
                    if !watchlistLog.isEmpty { logBlock(watchlistLog) }
                }

                Section("4. Review") {
                    Button("Write a review for Cowboy Bebop") {
                        demoReview()
                    }
                    if !reviewLog.isEmpty { logBlock(reviewLog) }
                }

                Section("5. Read back user state") {
                    Button("Print full user object") { demoReadback() }
                }
            }
            .navigationTitle("API + Store Demo")
        }
    }

    // MARK: - Demo functions

    func demoFetch() async {
        fetchLog = ["🔵 calling fetchAnimeFull(id: 1)..."]
        do {
            let json  = try await APIService.shared.fetchAnimeFull(id: 1)
            let data  = json["data"] as? [String: Any]
            animeTitle = data?["title"] as? String ?? "n/a"
            animeScore = "\(data?["score"] as? Double ?? 0)"
            fetchLog.append("🟢 title: \(animeTitle)")
            fetchLog.append("🟢 score: \(animeScore)")
            fetchLog.append("🟢 raw keys: \((data?.keys.sorted() ?? []).joined(separator: ", "))")
        } catch {
            fetchLog.append("🔴 \(error.localizedDescription)")
        }
    }

    func demoImages() async {
        fetchLog = ["🔵 calling fetchAniListImages(malId: 1)..."]
        do {
            let json   = try await APIService.shared.fetchAniListImages(malId: 1)
            let data   = json["data"]  as? [String: Any]
            let media  = data?["Media"] as? [String: Any]
            let cover  = media?["coverImage"] as? [String: Any]
            bannerURL  = media?["bannerImage"] as? String ?? "n/a"
            coverURL   = cover?["extraLarge"]  as? String ?? "n/a"
            fetchLog.append("🟢 banner: \(bannerURL)")
            fetchLog.append("🟢 cover:  \(coverURL)")
        } catch {
            fetchLog.append("🔴 \(error.localizedDescription)")
        }
    }

    func demoWatchlist() {
        watchlistLog = []
        LocalStore.shared.addToWatchList(id: 1, title: "Cowboy Bebop", status: .watching, score: nil)
        watchlistLog.append("✅ added to watchlist")
        LocalStore.shared.updateWatchList(id: 1, status: .watching, score: 9)
        watchlistLog.append("✅ score set to 9")
        let entry = LocalStore.shared.user.watchlist.first { $0.id == 1 }
        watchlistLog.append("📦 entry → id:\(entry?.id ?? 0) title:\(entry?.title ?? "") status:\(entry?.status.rawValue ?? "") score:\(entry?.score ?? 0)")
    }

    func demoReview() {
        reviewLog = []
        LocalStore.shared.addReview(
            Id: 1,
            title: "A timeless classic",
            body: "Cowboy Bebop is one of the greatest anime ever made.",
            isSpoiler: false
        )
        reviewLog.append("✅ review saved")
        let r = LocalStore.shared.user.reviews.first { $0.animeId == 1 }
        reviewLog.append("📦 review → title:\(r?.title ?? "") spoiler:\(r?.isSpoiler ?? false)")
    }
    
    func demoReadback() {
        let u = LocalStore.shared.user
        print("👤 name:      \(u.name)")
        print("👤 bio:       \(u.bio)")
        print("📺 watchlist: \(u.watchlist)")
        print("📝 reviews:   \(u.reviews)")
    }

    // MARK: - Helpers

    func row(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.caption2.monospaced()).lineLimit(2)
        }
    }

    func logBlock(_ lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(lines, id: \.self) {
                Text($0).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
        }
    }
}
