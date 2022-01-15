//
//  UserListView.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/7/22.
//

import SwiftUI

struct UserListWrapper: View {
    let params: [String: String]
    
    var body: some View {
        let userListViewModel = UserListViewModel(params: params)
        UserListView(viewModel: userListViewModel, functions: userListViewModel.getFunctions()).task { await userListViewModel.loadData() }
    }
}


struct UserListView: View {
    @ObservedObject var viewModel: UserListViewModel
    let functions: UserList.FunctionHolder?
    let show: Bool = true
    
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            }
            
            if viewModel.result != nil && !viewModel.result!.checkEmpty() {
                if let functions = functions {
                    UserListAction(users: viewModel.result!.users, functions: functions)
                } else {
                    UserListCore(users: viewModel.result!.users)
                }

            } else if !viewModel.isLoading {
                EmptyViewDecider(userListParams: viewModel.request.data.params, resultNil: viewModel.result == nil)
            }
        }
    }
}

struct UserListCore: View {
    let users: [UserCore]
    
    func getPadding(index: Int) -> CGFloat {
        return index == 0 ? 13: 7
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(0..<users.count, id: \.self) { index in
                    if let user = users[index] {
                        VStack(alignment: .leading) {
                            RelationshipHeader(user: user, size: 65)
                            .padding(.top, getPadding(index: index))
                            .padding(.bottom, 7)

                            Divider()
                                
                        }
                    }
                }
            }
        }
    }
}


struct UserListAction: View {
    @EnvironmentObject var tracker: RelationshipTracker
    @State var users: [UserCore]
    let functions: UserList.FunctionHolder
    
    func removeUser(index: Int) {
        self.users.remove(at: index)
    }
    
    
    func getPadding(index: Int) -> CGFloat {
        return index == 0 ? 13: 7
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(0..<users.count, id: \.self) { index in
                    let user = users[index]
                    VStack(alignment: .leading) {
                        if functions.type == .requests {
                            BoundRelationshipHeader(user: user, index: index, modelFunctions: functions, viewFunction: removeUser)
                        } else {
                            HStack {
                                RelationshipHeader(user: user, size: 65)
                                Spacer()
                                InviteButton(index: index, modelFunctions: functions)
                            }
                        }
                    }
                    .padding(.top, getPadding(index: index))
                    .padding(.bottom, 7)

                    Divider()
                }
            }
        }
        .onAppear {
            self.users = self.users.filter({ !tracker.isDeleted(key: $0.userID) })
        }
    }
}


struct BoundRelationshipHeader: View {
    @EnvironmentObject var tracker: RelationshipTracker
    
    let user: UserCore
    let index: Int
    var modelFunctions: UserList.FunctionHolder
    var viewFunction: (Int) -> Void
  
    func getRelationship() -> UserCore.Relationship? {
        if tracker.isFriend(key: user.userID) {
            return .FRIEND
        } else {
            return user.relationship
        }
    }
    
    var body: some View {
        HStack {
            NavigationLink {
                ProfileWrapper(params: Profile.getParams(otherID: user.userID, otherName: user.firstName))
            } label: {
                UserImageDecider(imageID: user.userID, size: 65)
            }
            
                .padding(.leading, 12)
            VStack(alignment: .leading) {
                HStack {
                    TitleString(text: user.firstName)
                    UserNameString(text: user.userName)
                }
                let relationship = getRelationship()
                if relationship == .CONNECTION {
                    NavigationLink {
                        UserListWrapper(params: UserList.getMutualFriendParams(otherID: user.userID, name: user.firstName))
                            .navigationTitle("Mutual Friends with \(user.firstName)")
                    } label: {
                        ConnectionString(rel: relationship, links: user.links)
                    }
                } else {
                    ConnectionString(rel: relationship, links: user.links)
                }
                
            }
            
            Spacer()
            
            if !tracker.isFriend(key: user.userID) {
                Button {
                    withAnimation(.linear(duration: 0.2)) {
                        tracker.friend_insert(key: user.userID)
                    }

                    
                    Task { await modelFunctions.accept!(index) }
                } label: {
                    Checkmark()
                        .padding(.trailing, 20)
                }
                
                Button {
                    withAnimation(.linear(duration: 0.2)) {
                        viewFunction(index)
                    }
                    tracker.deletedInsert(key: user.userID)
                    Task { await modelFunctions.delete!(index) }
                    
                } label: {
                    XMark()
                        .padding(.trailing, 20)
                }
                
            } else if tracker.isFriend(key: user.userID) {
                CheckmarkCircle()
                    .font(.system(size: 30))
                    .padding(.trailing, 20)
                
            }
        }
    }
}



struct DualUserListWrapper: View {
    let paramsOne: [String: String]
    let paramsTwo: [String: String]
    let labelOne: String
    let labelTwo: String
    
    var body: some View {
        let modelOne = UserListViewModel(params: paramsOne, key: paramsOne["otherID"]! + labelOne)
        let modelTwo = UserListViewModel(params: paramsTwo, key: paramsTwo["otherID"]! + labelTwo)
        DualUserListView(modelOne: modelOne, modelTwo: modelTwo, labelOne: labelOne, labelTwo: labelTwo)
    }
}


struct DualUserListView: View {
    @ObservedObject var modelOne: UserListViewModel
    @ObservedObject var modelTwo: UserListViewModel
    let labelOne: String
    let labelTwo: String
    
    @State private var selection: String
    
    init(modelOne: UserListViewModel, modelTwo: UserListViewModel, labelOne: String, labelTwo: String) {
        self.modelOne = modelOne
        self.modelTwo = modelTwo
        self.labelOne = labelOne
        self.labelTwo = labelTwo
        
        self.selection = labelOne
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ContentSelector(labels: [labelOne, labelTwo], selected: $selection)
                .padding(.top, 10)
            
            if selection == labelOne {
                UserListView(viewModel: modelOne, functions: modelOne.getFunctions()).task { await modelOne.loadData() }
            } else {
                UserListView(viewModel: modelTwo, functions: modelTwo.getFunctions()).task { await modelTwo.loadData() }
            }
        }
    }
}

struct DualUserListDecider: View {
    @ObservedObject var modelOne: UserListViewModel
    @ObservedObject var modelTwo: UserListViewModel
    
    @Binding var modelOneSelected: Bool
    var body: some View {
        if modelOneSelected {
            UserListView(viewModel: modelOne, functions: modelOne.getFunctions()).task { await modelOne.loadData() }
        } else {
            UserListView(viewModel: modelTwo, functions: modelTwo.getFunctions()).task { await modelTwo.loadData() }
        }
    }
}
