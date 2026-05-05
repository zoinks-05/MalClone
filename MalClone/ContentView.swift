//
//  ContentView.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 28/4/2026.
//
import SwiftUI

enum Tab {
    case home, top, search, profile, settings, demo
}

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View{
        VStack(spacing: 0){
            
            HStack(spacing: 8) {
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("NotMAL")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.4, green: 0, blue: 0.6))
            
            
            //NOTE Text(String) is temporary once you make a view
            // Example:
            // HomeView()
            // .tag
            // .tabItem
            TabView(selection: $selectedTab){
                HomeView()
                    .tag(Tab.home)
                    .tabItem{Label("Home", systemImage: "house.fill")}
                
                TopView()
                    .tag(Tab.top)
                    .tabItem{Label("Top", systemImage: "chart.bar.fill")}
                
                SearchView()
                    .tag(Tab.search)
                    .tabItem{Label("Search", systemImage: "magnifyingglass")}
                ProfileView()
                    .tag(Tab.profile)
                    .tabItem{Label("Profile", systemImage: "person.fill")}
                DemoView()
                    .tag(Tab.demo)
                    .tabItem{Label("demo", systemImage: "gearshape.fill")}
            }
            .tabViewStyle(.sidebarAdaptable)
        }
    }
}

#Preview {
    ContentView()
}
