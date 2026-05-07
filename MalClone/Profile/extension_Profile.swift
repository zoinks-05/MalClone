//
//  extension_Profile.swift
//  MalClone
//
//  Created by Brian Tran on 7/5/2026.
//

import SwiftUI

extension ProfileView {
    func editProfile(username: String, bio: String) -> some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.crop.circle")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 75))
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                
                List {
                    Section("Enter New Username:") {
                        TextField(username, text: $newUsername)
                    }
                    
                    Section("Enter New Bio") {
                        TextField(bio, text: $newBio)
                    }
                }
                    Button("Save"){
                        LocalStore.shared.updateProfile(name: newUsername, bio: newBio)
                        showEditProfileSheet = false
                    }
                    .disabled(newUsername.isEmpty && newBio.isEmpty)
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 100))
                
                    .onAppear {
                        if !username.isEmpty || !bio.isEmpty{
                            newUsername = username
                            newBio = bio
                        }
                    }
            }
        }
    }
}
