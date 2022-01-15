//
//  Menu.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI

//class NavigationContainer: ObservableObject {
//    @Published var hostEvent = false
//    @Published var editProfile = false
//    @Published var addInvites = false
//    @Published var addToGroup = false
//    @Published var removeFromGroup = false
//
//}

struct AppMenu: View {
    let userID: String
    
//    @EnvironmentObject var firebaseAuthManager: FirebaseAuthManager
    
    @State var selectedTab: Tab = .events
    @State var newEventsIsActive = false
    @State var showBottomTabBar = true
    @State var editProfile = false
    
    @State var showEventCreator: Bool = false
    @State var showWhich: String = "First"
    
    @StateObject var eventCreator = EventCreator()
    @StateObject var feedViewModel = FeedViewModel(params: Feed.getFutureParams(), key: "future events")
    @StateObject var profileViewModel = ProfileViewModel(params: Profile.getParams(otherID: USER_ID.instance.get()!, otherName: "name"))
    @StateObject var requestViewModel = UserListViewModel(params: UserList.getParams(otherID: USER_ID.instance.get()!, type: "receivedRequests"))
    @Environment(\.scenePhase) var scenePhase
    
    init(userID: String) {
        self.userID = userID
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = .white
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance

    }
    
    
    


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if selectedTab == .events {
                    FutureFeedViewer(feedViewModel: feedViewModel, eventCreationIsActive: $showEventCreator)
                        .task { await feedViewModel.loadData() }

                   
                } else if selectedTab == .groups {
//                    GroupsViewWrapper(params: FriendGroup.getParams(), key: "groups")
//                        .navigationTitle("Groups")

                } else if selectedTab == .search {
                    SearchView(showBottomTabBar: $showBottomTabBar)
                    
                } else if selectedTab == .requests {
                    UserListView(viewModel: requestViewModel, functions: requestViewModel.getFunctions())
                        .task { await requestViewModel.loadData() }
                        .navigationTitle("Friend Requests")
            

                } else if selectedTab == .profile {
                    ProfileView_NEW(profileViewModel: profileViewModel)
                        .task { await profileViewModel.loadData() }
                        .navigationTitle("Profile")
                       
                }
                
                Spacer(minLength: 0)
                if showBottomTabBar {
                    Divider()
                    TabBar
                }
                
                NavigationLink(destination: Text("Edit Profile"), isActive: $editProfile) { EmptyView() }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    if selectedTab == .events {
                        Task { await feedViewModel.loadData(ensureImage: true) }
                    }
                } 
            }
            .fullScreenCover(isPresented: $showEventCreator) {
                if showWhich == "First" {
                    EventDetails(showAny: $showEventCreator, showWhich: $showWhich, eventCreator: eventCreator)
                } else {
                    Invites(showAny: $showEventCreator, showWhich: $showWhich, eventCreator: eventCreator, function: feedViewModel.loadData)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(VERSION.num)
                        .font(.system(size: 12, weight: .light))
                }
                
                ToolbarItem(placement: .principal) {
                    if selectedTab == .events {
                        Button {
                            Task { await feedViewModel.loadData(manualOverride: true) }
                        } label: {
                            Image("NavigationBarLogo")
                                .resizable()
                                .frame(width: 40, height: 40)
//                            NavigationBarLogo()
//                            Hexagon()
//                                .stroke(LinearGradient(colors: [COLORS.PRIMARY, COLORS.SECONDARY], startPoint: .topLeading, endPoint: .bottomTrailing),
//                                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
//                                .frame(width: 40, height: 40 * Hexagon.heightWidthRatio)
                        }
                    }
                }
                
                
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == .events {
                        Button {
                            showEventCreator = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    
                                
                                Text("Event")
                                    .foregroundColor(.black)
                                    .font(.system(size: 15))
                            }
                        }
                    } else if selectedTab == .groups {
                        NavigationLink(destination: CreateGroup(userID: userID)) {
                            Text("Create Group")
                                .foregroundColor(COLORS.PRIMARY)
                                .font(.system(size: 15))
                        }
                    } else if selectedTab == .profile {
                        ProfileOptions(editProfileLink: $editProfile)
                    }
                }
            }
        }
    }
    
    private var TabBar: some View {
        ZStack {
            Color.white
                .frame(height: 40)
//                .shadow(color: .gray.opacity(0.25), radius: 2, x: 0, y: -2)
            
            HStack {
                BottomTabBarItem(name: "note.text", selectedName: "note.text", directedTab: .events, selectedTab: $selectedTab)
                    .padding(.leading, 20)
                Spacer()
//                BottomTabBarItem(name: "person.3", selectedName: "person.3.fill", directedTab: .groups, selectedTab: $selectedTab)
//                Spacer()
                BottomTabBarItem(name: "magnifyingglass", selectedName: "magnifyingglass", directedTab: .search, selectedTab: $selectedTab)
                Spacer()
                BottomTabBarItem(name: "bell", selectedName: "bell.fill", directedTab: .requests, selectedTab: $selectedTab)
                Spacer()
                BottomTabBarItem(name: "person", selectedName: "person.fill", directedTab: .profile, selectedTab: $selectedTab)
                    .padding(.trailing, 20)
            }
            .padding(.top, 20)
        
        }
    }
}



struct BottomTabBarItem: View {
    let name: String
    let selectedName: String
    
    let directedTab: Tab
    @Binding var selectedTab: Tab
    
    private func getWeight() -> Font.Weight {
        if selectedTab == directedTab {
            return .bold
        } else {
            return .light
        }
        
    }
    
    var body: some View {
        Button {
            selectedTab = directedTab
        } label: {
            Image(systemName: selectedTab == directedTab ? selectedName: name)
                .font(.system(size: 20, weight: getWeight()))
                .foregroundColor(.black)
                .opacity(0.85)
        }
    }
}



enum Tab: String {
    case events
    case requests
    case profile
    case utilities
    case groups
    case search
    case temp
}



struct UtilitiesView: View {
    @State var isLoading = false
    @EnvironmentObject var firebaseAuthManager: FirebaseAuthManager
    
    
    var body: some View {
        VStack {
            Button {
                firebaseAuthManager.signOut()
            } label: {
                Text("Sign Out")
            }
            .padding(.bottom, 20)

            
            Button {
                URLCache.shared.removeAllCachedResponses()
            } label: {
                Text("Remove All")
            }
            .padding(.bottom, 20)
        
        }
    }
}

struct NavigationBarLogo: View {
    var body: some View {
        VStack {
            Hexagon()
                .stroke(LinearGradient(colors: [COLORS.PRIMARY, COLORS.SECONDARY], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .frame(width: 40, height: 40 * Hexagon.heightWidthRatio)
                .padding(.bottom, 7)
//            Color.white
//                .frame(height: 5)
        }
    }
}
