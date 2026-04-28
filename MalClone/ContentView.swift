//
//  ContentView.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//
import SwiftUI

struct ContentView: View {
    @State private var title = "Loading..."

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(title)
        }
        .padding()
        .task {
            do {
                print("🔵 fetching anime id 1...")
                let json = try await APIService.shared.fetchAnimeFull(id: 1)
                print("🟢 raw response: \(json)")
                
                let data = json["data"] as? [String: Any]
                print("🟢 data block: \(String(describing: data))")
                
                title = data?["title"] as? String ?? "no title"
                print("🟢 title: \(title)")
            } catch {
                print("🔴 error: \(error)")
                title = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
