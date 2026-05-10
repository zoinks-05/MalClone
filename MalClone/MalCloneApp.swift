//
//  MalCloneApp.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//

import SwiftUI

@main
struct MalCloneApp: App {
    init(){
        // Default Purple Tone
        UIView.appearance().tintColor = UIColor(.purple)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalStore.shared)
        }
    }
}

