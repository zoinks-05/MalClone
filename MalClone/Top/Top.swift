//
//  Top.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 29/4/2026.
//

import SwiftUI

struct TopView: View{
    @State private var selectedTab = 0
    var body: some View{
        Picker("", selection: $selectedTab){
            Text("All").tag(0)
            Text("Anime").tag(1)
            Text("Movie").tag(2)
            Text("OVA").tag(3)
        }
        .pickerStyle(.segmented)
        .padding(12)
    }
}
