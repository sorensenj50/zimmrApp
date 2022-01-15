//
//  Groups.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI

//struct GroupsViewWrapper: View {
//    let params: [String: String]
//    let key: String?
//    var body: some View {
//        let groupsViewModel = GroupsViewModel(params: params, key: key)
//        GroupsViewer(groupsViewModel: groupsViewModel).task { await groupsViewModel.loadData() }
//    }
//}
//
//
//
//struct GroupsViewer: View {
//    @ObservedObject var groupsViewModel: GroupsViewModel
//    var body: some View {
//        if groupsViewModel.isLoading {
//            TaskLoadingView()
//        } else if groupsViewModel.result == nil || groupsViewModel.result!.groups.isEmpty {
//            EmptyViewDecider(emptyType: .allGroups)
//        } else {
//            GroupsViewCore(groups: groupsViewModel.result!.groups)
//        }
//    }
//}
//
//struct GroupsViewCore: View {
//    let groups: [FriendGroup]
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 0) {
//                ForEach(groups) { group in
//                    GroupCoreView(group: group)
//                        .padding(.vertical, 15)
//                    Divider()
//                }
//            }
//        }
//    }
//}
//
//struct GroupCoreView: View {
//    let group: FriendGroup
//    var body: some View {
//        HStack {
//            NavigationLink(destination: GroupOverallView(group: group)) {
//                GroupImageDecider(imageID: group.groupID, size: 65)
//            }
//            HStack(alignment: .top) {
//                VStack(alignment: .leading) {
//                    HStack {
//                        TitleString(text: group.groupName)
//                        Spacer()
//                        MostRecentMessageDate(unixDate: group.mostRecentMessageDate)
//
//                           
//                    }
//                    MostRecentMessageText(text: group.mostRecentMessage)
//
//                        
//                    Spacer(minLength: 0)
//                }
//                .frame(height: 70)
//            }
//        }
//        .padding(.leading, 12)
//        .padding(.trailing, 12)
//    }
//}
//
//
//struct GroupCardView: View {
//    let group: FriendGroup
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                GroupImageDecider(imageID: group.groupID, size: 100)
//                VStack(alignment: .leading) {
//                    TitleString(text: group.groupName, size: )
//                    Text("\(group.numMembers)" + " " + "members")
//                        .font(.system(size: 15, weight: .light))
//                    ConnectionString(interpretedRelationship: FriendGroup.interpretRelationship(group.relationshipToGroup))
//                }
//                
//                Spacer()
//            }
//            
//            if group.relationshipToGroup == .GROUP_MEMBER_REQUEST {
//                GroupRequestToggler()
//            }
//        }
//        .padding(.top, 20)
//        .padding(.leading, 20)
//        .padding(.bottom, 20)
//        
//    }
//}
//
//struct GroupOverallView: View {
//    let group: FriendGroup
//    
//    @State var selected: String = "Past Events"
//    var body: some View {
//        VStack {
//            GroupCardView(group: group)
//            ContentSelector(labels: ["Past Events", "Members"], selected: $selected)
//        
//            Spacer()
//            
//        }
//        .navigationTitle(group.groupName)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                OptionsEllipsis()
//            }
//        }
//    }
//}
//
//struct GroupRequestToggler: View {
//    var body: some View {
//        Text("Group Request")
//    }
//}
//
//
//struct MostRecentMessageText: View {
//    let text: String
//    var body: some View {
//        Text(text)
//            .foregroundColor(.gray)
//            .font(.system(size: 16, weight: .light))
//            .truncationMode(.tail)
//    }
//}
//          
//
//struct MostRecentMessageDate: View {
//    let date: String
//    
//    init(unixDate: Double) {
//        self.date = parseGroupsRecentMessageDate(unixDate: unixDate)
//    }
//    
//    var body: some View {
//        Text(date)
//            .font(.system(size: 14, weight: .regular))
//    }
//}









        
