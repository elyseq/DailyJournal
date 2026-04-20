//
//  ProfileSetupView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/16/26.
//

// TODO: Re-enable when CloudKit is configured
// Profile setup is commented out until a shared backend (CloudKit) is set up.

/*
import SwiftUI
import SwiftData

struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var username: String = ""
    @State private var errorMessage: String?

    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(.purple)

            Text("Set Up Your Profile")
                .font(.title.weight(.bold))

            Text("Choose a unique username so friends can find you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(spacing: 12) {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .padding(.horizontal, 40)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Button {
                createProfile()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(username.count >= 3 ? Color.purple : Color.gray.opacity(0.3))
                    )
                    .foregroundStyle(.white)
            }
            .disabled(username.count < 3)
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    private func createProfile() {
        let trimmed = username.trimmingCharacters(in: .whitespaces).lowercased()

        guard trimmed.count >= 3 else {
            errorMessage = "Username must be at least 3 characters."
            return
        }

        guard trimmed.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) else {
            errorMessage = "Only letters, numbers, and underscores allowed."
            return
        }

        // Check for duplicates locally
        let existing = profiles.first { $0.username == trimmed }
        if existing != nil {
            errorMessage = "That username is already taken."
            return
        }

        let profile = UserProfile(username: trimmed)
        modelContext.insert(profile)
        try? modelContext.save()
        onComplete()
    }
}
*/
