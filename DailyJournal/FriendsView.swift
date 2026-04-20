//
//  FriendsView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/16/26.
//

// TODO: Re-enable when CloudKit is configured
// All friends functionality is commented out until a shared backend (CloudKit) is set up.

/*
import SwiftUI
import SwiftData

struct FriendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var friends: [Friend]
    @Query private var profiles: [UserProfile]

    @State private var showingAddSheet = false
    @State private var showingShareSheet = false

    private var myProfile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                // Your profile card
                if let profile = myProfile {
                    Section("Your Profile") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.purple)
                                Text(profile.username)
                                    .font(.title3.weight(.semibold))
                            }
                            HStack {
                                Text("Friend Code:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(profile.friendCode)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.purple)
                            }
                        }
                        .padding(.vertical, 4)

                        ShareLink(
                            item: friendInviteURL,
                            subject: Text("Add me on DailyJournal!"),
                            message: Text("Add me as a friend on DailyJournal! My username is \(profile.username)")
                        ) {
                            Label("Share Invite Link", systemImage: "square.and.arrow.up")
                        }
                    }
                }

                // Friends list
                Section("Friends (\(friends.count))") {
                    if friends.isEmpty {
                        Text("No friends yet. Tap + to add someone!")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(friends) { friend in
                            friendRow(friend)
                        }
                        .onDelete(perform: removeFriends)
                    }
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddFriendSheet()
            }
        }
    }

    private var friendInviteURL: URL {
        let profile = myProfile
        let username = profile?.username ?? ""
        let code = profile?.friendCode ?? ""
        return URL(string: "dailyjournal://add-friend?username=\(username)&code=\(code)")!
    }

    private func friendRow(_ friend: Friend) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle")
                .font(.title2)
                .foregroundStyle(.purple.opacity(0.7))

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.username)
                    .font(.body.weight(.medium))
                Text("Added \(friend.addedAt.formatted(.dateTime.month(.abbreviated).day().year()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func removeFriends(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(friends[index])
        }
        try? modelContext.save()
    }
}

// MARK: - Add Friend Sheet

struct AddFriendSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var friends: [Friend]
    @Query private var profiles: [UserProfile]

    @State private var username: String = ""
    @State private var friendCode: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.purple)

                    Text("Add a Friend")
                        .font(.title2.weight(.bold))

                    Text("Enter their username and friend code to add them.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                VStack(spacing: 12) {
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif

                    TextField("Friend Code", text: $friendCode)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                }
                .padding(.horizontal, 32)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if let successMessage {
                    Text(successMessage)
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                Button {
                    addFriend()
                } label: {
                    Text("Add Friend")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(canAdd ? Color.purple : Color.gray.opacity(0.3))
                        )
                        .foregroundStyle(.white)
                }
                .disabled(!canAdd)
                .padding(.horizontal, 32)

                Spacer()
            }
            .navigationTitle("Add Friend")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var canAdd: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !friendCode.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func addFriend() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces).lowercased()
        let trimmedCode = friendCode.trimmingCharacters(in: .whitespaces).lowercased()

        errorMessage = nil
        successMessage = nil

        // Don't add yourself
        if let myProfile = profiles.first, myProfile.username == trimmedUsername {
            errorMessage = "You can't add yourself as a friend."
            return
        }

        // Check if already friends
        if friends.contains(where: { $0.username == trimmedUsername }) {
            errorMessage = "\(trimmedUsername) is already your friend."
            return
        }

        let friend = Friend(username: trimmedUsername, friendCode: trimmedCode)
        modelContext.insert(friend)
        try? modelContext.save()

        successMessage = "\(trimmedUsername) added as a friend!"
        username = ""
        friendCode = ""
    }
}
*/
