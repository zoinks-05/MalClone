//
//  Helpers.swift
//  MalClone
//
//  Created by Ziyan Nadeem on 3/5/2026.
//
import SwiftUI

func imageURL(_ anime: [String: Any]) -> URL? {
    let images = anime["images"] as? [String: Any]
    let jpg    = images?["jpg"]  as? [String: Any]
    return URL(string: jpg?["image_url"] as? String ?? "")
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

func columns(for w: CGFloat)  -> Int {
    if w >= 1024 { return 6}
    if w >= 768 {return 4}
    return 2
}
