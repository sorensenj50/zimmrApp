//
//  EmptyViews.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI


struct NoNetworkView: View {
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60, weight: .thin))
                .padding(.bottom, 9)
                .foregroundColor(.gray)
            
            Text("No Network Connection")
                .font(.system(size: 23, weight: .medium))
                .padding(.bottom, 9)
            
            Text("Have fun in the real world!")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.gray)
            
        }
    }
}




struct EmptyViewDecider: View {
    
    enum EmptyType {
        case noEvent
        case selfPastEvent
        case otherPastEvent
        case request
        case selfFriend
        case otherFriend
        case selfConnection
        case otherConnection
        case invite
        case attend
        case eventMessage
        case mutualFriends
        case beforeSearch
        case emptySearch
        case allGroups
        case profile
    }
    // add case search
    
    let emptyType: EmptyType
    var name: String? = nil
    
    init(feedParams: [String: String]) {
        
        if feedParams["time"] == "future" {
            self.emptyType = .noEvent
        } else if feedParams["userID"]! == feedParams["otherID"]! {
            self.emptyType = .selfPastEvent
        } else {
            self.emptyType = .otherPastEvent
            self.name = feedParams["otherName"]!
        }
    }

    
    
    init(userListParams: [String: String], resultNil: Bool) {
        let type = userListParams["type"]!
        let userID = userListParams["userID"]!
        let otherID = userListParams["otherID"]!
    
        
        if type == "receivedRequests" {
            self.emptyType = .request
        } else if type == "invite" {
            self.emptyType = .invite
        } else if type == "attend" {
            self.emptyType = .attend
        } else if type == "friends" {
            if userID == otherID {
                self.emptyType = .selfFriend
            } else {
                self.emptyType = .otherFriend
                self.name = userListParams["otherName"]!
            }
        } else if type == "connections" {
            if userID == otherID {
                self.emptyType = .selfConnection
            } else {
                self.emptyType = .otherConnection
                self.name = userListParams["otherName"]!
            }
        } else if type == "mutualFriends" {
            self.emptyType = .mutualFriends
            self.name = userListParams["otherName"]
        } else if type == "search" && resultNil {
            emptyType = .beforeSearch
        } else if type == "search" && !resultNil {
            emptyType = .emptySearch
        } else {
            emptyType = .eventMessage
        }
    }
        
    
    init(emptyType: EmptyType) {
        self.emptyType = emptyType
    }
    
    
    var body: some View {
        switch emptyType {
        case .noEvent:
            EmptyContentView(title: "No Events", subTitle: "Events that you're invited to or attending will show up here", imageName: "note.text")
        case .selfPastEvent:
            EmptyContentView(title: "No Past Events", subTitle: "Events that you've attended or hosted will show up here", imageName: "note.text")
        case .otherPastEvent:
            EmptyContentView(title: "No Past Events", subTitle: "Events that \(name!) has attended or hosted will show up here", imageName: "note.text")
        case .request:
            EmptyContentView(title: "No Requests", subTitle: "People who send you friend requests will show up here", imageName: "bell")
        case .selfFriend:
            EmptyContentView(title: "No Friends", subTitle: "Your friends will show up here", imageName: "person.2")
        case .otherFriend:
            EmptyContentView(title: "No Friends", subTitle: "\(name!)'s friends will show up here", imageName: "person.2")
        case .selfConnection:
            EmptyContentView(title: "No Connections", subTitle: "The friends of your friends will show up here", imageName: "person.3.sequence")
        case .otherConnection:
            EmptyContentView(title: "No Connections", subTitle: "The friends of \(name!)'s friends will show up here", imageName: "person.3.sequence")
        case .invite:
            EmptyContentView(title: "No Users", subTitle: "People who are invited to this event will show up here", imageName: "person.3.sequence")
        case .attend:
            EmptyContentView(title: "No Users", subTitle: "People who are planning on attending this event will show up here", imageName: "person.3.sequence")
        case .eventMessage:
            EmptyContentView(title: "No Messages ", subTitle: "Messages for this event will show up here", imageName: "bubble.left")
        case .mutualFriends:
            EmptyContentView(title: "No Mutual Friends", subTitle: "Friends that you and \(name!) both have will show up here", imageName: "person.2")
        case .beforeSearch:
            EmptyContentView(title: "Search", subTitle: "People you search for will show up here", imageName: "magnifyingglass")
        case .emptySearch:
            EmptyContentView(title: "No Results", subTitle: "Try again with a different name or username", imageName: "person.3.sequence")
        case .allGroups:
            EmptyContentView(title: "No Groups", subTitle: "Groups that you are a member of will show up here", imageName: "person.3")
        case .profile:
            EmptyContentView(title: "No Profile", subTitle: "We couldn't find this person. There's probably been an error", imageName: "person")
        }
    }
}

enum LinkType {
    case hostEvent
    case searchForFriends
    case createGroup
}



struct EmptyContentViewCore: View {
    let title: String
    let subTitle: String?
    let imageName: String
    
    var body: some View {
        VStack(spacing: 0) {
//                Spacer()
            Image(systemName: imageName)
                .font(.system(size: 60, weight: .thin))
                .padding(.bottom, 9)
                .foregroundColor(.gray)
            
            EmptyTitle(text: title)
                .padding(.bottom, 9)
            
            if let subTitle = subTitle {
                EmptySubtitle(text: subTitle)
                    .padding(.bottom, 7)
                    .padding(.bottom, 9)
            }
            
        }
        .frame(width: 250)
    }
}


struct EmptyContentView: View {

    let title: String
    let subTitle: String?
    let imageName: String
    

    var body: some View {
        VStack {
            Spacer()
            EmptyContentViewCore(title: self.title, subTitle: self.subTitle, imageName: self.imageName)
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}

struct EmptyContentViewButtonWrapper: View {
    let title: String
    let subTitle: String?
    let imageName: String
    @Binding var buttonShow: Bool
    

    var body: some View {
        VStack {
            Spacer()
            EmptyContentViewCore(title: self.title, subTitle: self.subTitle, imageName: self.imageName)
            Button {
                buttonShow = true
            } label: {
                FilledImageRectangle(text: "Host Event", systemImageName: "plus", color: COLORS.PRIMARY, size: 16)
            }
            Spacer()
        }
    }
}

struct FilledImageRectangle: View {
    let text: String
    let systemImageName: String
    let color: Color
    let size: CGFloat
    let opacity: CGFloat
    
    init(text: String, systemImageName: String) {
        self.text = text
        self.systemImageName = systemImageName
        self.color = COLORS.PRIMARY
        self.size = 16
        self.opacity = 1.0
    }
    
    init(text: String, systemImageName: String, color: Color, size: CGFloat) {
        self.text = text
        self.systemImageName = systemImageName
        self.color = color
        self.size = size
        self.opacity = 1.0
    }
    
    init(text: String, systemImageName: String, color: Color, size: CGFloat, opacity: CGFloat) {
        self.text = text
        self.systemImageName = systemImageName
        self.color = color
        self.size = size
        self.opacity = opacity
    }
    
    
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: systemImageName)
                .font(.system(size: size, weight: .bold))
                .padding(.trailing, 5)
            
            Text(text)
                .font(.system(size: size, weight: .bold))
        }
        .opacity(0)
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(color)
                .opacity(opacity)
                .overlay(
                    HStack {
                        Image(systemName: systemImageName)
                            .foregroundColor(.white)
                            .font(.system(size: size, weight: .bold))
                           

                        Text(text)
                            .foregroundColor(.white)
                            .font(.system(size: size, weight: .bold))
                            .padding(.trailing, 5)

                        }
                    )
        )
    }
}



