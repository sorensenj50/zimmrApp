//
//  Profile.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI

struct ProfileWrapper: View {
    let params: [String: String]
    var body: some View {
        let profileViewModel = ProfileViewModel(params: params)
        ProfileView_NEW(profileViewModel: profileViewModel).task { await profileViewModel.loadData() }
    }
}

struct ProfileCardView: View {
    static let imageSize: CGFloat = 100
    
    let user: User
    let functions: Profile.FunctionHolder
    @State var relationship: UserCore.Relationship?
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                UserImageDecider(imageID: user.id, size: ProfileCardView.imageSize)


                VStack(alignment: .leading, spacing: 2) {
                    
                    Group {
                        TitleString(text: user.core.fullName, size: TitleString.profile)
                        UserNameString(text: user.core.userName, size: UserNameString.profile)
//                        ConnectionStringMutualFriends(user: user.core, size: ConnectionString.profile)
                        ConnectionStringManual(rel: $relationship, user: user.core)
                    }
                    .frame(alignment: .leading)
                }
                Spacer()
            }
            .padding(.bottom, 2)

            RequestButtons(user: user.core, requestStatus: user.requestStatus, relationship: $relationship, functions: functions)

        }
        .padding(.top, 20)
        .padding(.leading, 20)
        .padding(.bottom, 20)
    }
}

struct ProfileView_NEW: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        if profileViewModel.isLoading {
            LoadingView()
        } else if profileViewModel.result != nil && profileViewModel.result!.user != nil {
            VStack(spacing: 0) {
                ProfileCardView(user: profileViewModel.result!.user!, functions: profileViewModel.getFunctions(), relationship: profileViewModel.result!.user!.core.relationship)

                let pastFeedViewModel = FeedViewModel(feed: profileViewModel.result!.pastEvents, params: profileViewModel.request.data.params)
                let friendsViewModel = UserListViewModel(params: profileViewModel.getFriendParams(), key: "friends")
                let connectionsViewModel = UserListViewModel(params: profileViewModel.getConnectionsParams(), key: "connections")

                BottomProfileLists(pastFeedViewModel: pastFeedViewModel, friendViewModel: friendsViewModel, connectionsViewModel: connectionsViewModel)
                    .padding(.top, -1)
                    .clipped()
                
            }
            .navigationTitle(profileViewModel.result!.user!.core.firstName)
            .edgesIgnoringSafeArea([.bottom])
        } else {
            EmptyViewDecider(emptyType: .profile)
        }
    }
}

struct ProfileView_Old: View {
    @ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
        if profileViewModel.isLoading {
            LoadingView()
        } else if profileViewModel.result != nil && profileViewModel.result!.user != nil {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    ProfileCardView(user: profileViewModel.result!.user!, functions: profileViewModel.getFunctions(), relationship: profileViewModel.result!.user!.core.relationship)

                    let pastFeedViewModel = FeedViewModel(feed: profileViewModel.result!.pastEvents, params: profileViewModel.request.data.params)
                    let friendsViewModel = UserListViewModel(params: profileViewModel.getFriendParams(), key: "friends")
                    let connectionsViewModel = UserListViewModel(params: profileViewModel.getConnectionsParams(), key: "connections")

                    BottomProfileLists(pastFeedViewModel: pastFeedViewModel, friendViewModel: friendsViewModel, connectionsViewModel: connectionsViewModel)
                        .padding(.top, -1)
                        .clipped()
                    
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .navigationTitle(profileViewModel.result!.user!.core.firstName)
            }
        } else {
            EmptyViewDecider(emptyType: .profile)
        }
    }
}



struct BottomProfileLists: View {
    let pastFeedViewModel: FeedViewModel
    let friendViewModel: UserListViewModel
    let connectionsViewModel: UserListViewModel

    @State var selection: String = "Past Events"

    var body: some View {
        ContentSelector(labels: ["Past Events", "Friends", "Connections"], selected: $selection)

        if selection == "Past Events" {
            FeedViewer(feedViewModel: pastFeedViewModel)
        } else if selection == "Friends" {
            UserListView(viewModel: friendViewModel, functions: friendViewModel.getFunctions()).task { await friendViewModel.loadData() }
        } else if selection == "Connections" {
            UserListView(viewModel: connectionsViewModel, functions: connectionsViewModel.getFunctions()).task { await connectionsViewModel.loadData() }
        }
    }
}


struct RequestButtons: View {
    @EnvironmentObject var tracker: RelationshipTracker
    let user: UserCore
    @State var requestStatus: User.RequestStatus?
    @Binding var relationship: UserCore.Relationship?
    let functions: Profile.FunctionHolder

    
    var body: some View {
        HStack {
            Spacer()
            if relationship == .SELF {
                EmptyView()
                    
                
            } else if relationship == .FRIEND {
                EmptyView()

            } else if requestStatus == .SENT || tracker.sendCheck(key: user.userID) {
                    OutlinedHeaderRectangle(string: "Pending... ", systemImageName: "person.2", color: COLORS.SECONDARY)
                        .opacity(0.5)
                
            } else if requestStatus == nil {
                Button {
                    self.requestStatus = .SENT
                    tracker.sendInsert(key: user.userID)
                    Task { await functions.send() }
                } label: {
                    OutlinedHeaderRectangle(string: "Add Friend ", systemImageName: "person.2", color: COLORS.SECONDARY)
                }

            } else if requestStatus == .RECEIVED {
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            self.relationship = .FRIEND
                            self.tracker.friend_insert(key: user.userID)
                            Task { await functions.accept() }
                            
                        } label: {
                            Text("Accept")
                                .foregroundColor(COLORS.SECONDARY)
                                .font(.system(size: 17))
                            Image(systemName: "checkmark")
                                .foregroundColor(COLORS.SECONDARY)
                                .font(.system(size: 30))
                                .padding(.trailing, 50)
                            
                        }
                        
                        Button {
                            self.requestStatus = nil
                            self.tracker.deletedInsert(key: user.userID)
                            Task { await functions.decline() }
                        } label: {
                            Text("Decline")
                                .foregroundColor(.red)
                                .font(.system(size: 17))
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                                .font(.system(size: 30))
                        }
                    }

                    Text("\(user.firstName) wants to be your friend!")
                        .font(.system(size: 13, weight: .light))
                        .padding(.top, 5)
                }
            }
            Spacer()
        }
    }
}

struct ProfileOptions: View {
    @Binding var editProfileLink: Bool
    @EnvironmentObject var firebaseAuthManager: FirebaseAuthManager
    
    var body: some View {
        Menu {
//            Button {
//               editProfileLink = true
//            } label: {
//                Text("Edit Profile")
//            }

            Button {
                firebaseAuthManager.signOut()
            } label: {
                Text("Sign Out")
            }
            
            Button {
                URLCacheManager.instance.removeAll()
            } label: {
                Text("Clear Cache")
            }

        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.black)
        }
    }
}

struct ConnectionStringManual: View {
    
    @Binding var rel: UserCore.Relationship?
    let user: UserCore
    
    
    var body: some View {
        if rel == .CONNECTION {
            NavigationLink {
                UserListWrapper(params: UserList.getMutualFriendParams(otherID: user.userID, name: user.firstName))
                    .navigationTitle("Mutual Friends with \(user.firstName)")
            } label: {
                ConnectionString(rel: rel, links: user.links, size: ConnectionString.profile)
            }
        } else {
            ConnectionString(rel: rel, links: user.links, size: ConnectionString.profile)
        }
    }
}


