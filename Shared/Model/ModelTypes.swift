//
//  ModelTypes.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import Foundation
import SwiftUI

struct StatusResponse: Codable {
    let status: String
}

struct ExistenceResponse: Codable {
    let exists: Bool
}

struct NewRelationship: Codable {
    let relationship: UserCore.Relationship?
    let links: Int?
}



protocol ModelEntryPoint {
    func checkEmpty() -> Bool
    func getReferences() -> Set<String>
}



struct Event: Codable, Identifiable {
    var id: String { return eventID }
    let eventID: String
    let core: UserCore
    let description: String
    let date: Double
    var numAttending: Int
    var numInvited: Int
    var numberMessages: Int
    var numMessagesSeen: Int
    var relationshipToEvent: Event.Relationship?
    
    
    
    enum Relationship: String, Codable {
        case INVITE
        case ATTEND
        case HOST
        case DISMISS
    }
    
    enum Position: String {
        case top
        case middle
        case bottom
        case single
        case detailed
    }
    
    struct FunctionHolder {
        var attend: ((String) async -> Void)?
        var dismiss: ((String, Event.Relationship) async -> Void)?
        var remove: ((String) -> Void)?
        var updateNumberMessages: ((String, Int) async -> Void)?
    }
}


struct Feed: Codable, ModelEntryPoint {
    var events: [Event]
    let firstName: String?
    
    enum Time: String {
        case future
        case past
    }
    
    func checkEmpty() -> Bool {
        return events.isEmpty
    }
    
    func getReferences() -> Set<String> {
        return Set(events.filter({ $0.core.hasImage }).map({ $0.core.userID }))
    }
    
    static func getFutureParams() -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "otherID": USER_ID.instance.get()!, "time": "future"]
    }
    
    static func getPastParams(otherID: String, otherName: String) -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "otherID": otherID, "time": "past", "otherName": otherName]
    }
    
    static func newEventParams() -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "eventID": UUID().uuidString]
    }
}


struct UserList: Codable, ModelEntryPoint {
    let users: [UserCore]
    
    enum functionType: String {
        case hostEvent
        case requests
    }
    
    struct FunctionHolder {
        let type: UserList.functionType
        var toggleInvite: ((Int) async -> Void)?
        var isInvited: ((Int) -> Bool)?
        
        var accept: ((Int) async -> Void)?
        var delete: ((Int) async -> Void)?
    }

    
    func checkEmpty() -> Bool {
        return users.isEmpty
    }
    
    func getReferences() -> Set<String> {
        return Set(users.filter({ $0.hasImage }).map({ $0.userID }))
    }
    
    static func getParams(otherID: String, type: String) -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "otherID": otherID, "type": type]
    }
    
    static func getMutualFriendParams(otherID: String, name: String) -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "type": "mutualFriends", "otherID": otherID, "otherName": name]
    }
    
}

struct UserCore: Codable, Identifiable {
    
    // information stored in the user node
    let userID: String
    let firstName: String
    let userName: String
    let fullName: String
    let hasImage: Bool
    
    // essential relational info
    var relationship: Relationship?
    var links: Int?
    
    // computed properties
    var id: String { return userID }
    
    
    enum Relationship: String, Codable {
        case FRIEND
        case CONNECTION
        case SELF
    }
    
    static func interpretRelationship(_ relationship: UserCore.Relationship?, _ links: Int?) -> String {
        if relationship == nil {
            return "no relationship"
        } else if relationship == .FRIEND {
            return "friend"
        } else if relationship == .CONNECTION {
            if links! == 1 {
                return "1 mutual friend"
            } else {
                return "\(links!) mutual friends"
            }
        } else if relationship == .SELF {
            return "yourself"
        } else {
            return ""
        }
    }
}


struct User: Codable, Identifiable {
    var id: String { return core.id }
    
    var core: UserCore
    var requestStatus: RequestStatus?

    
    struct Params {
        let userID: String
        let otherID: String
    }
    
    enum RequestStatus: String, Codable {
        case SENT
        case RECEIVED
    }
    
    struct FunctionHolder {
        var toggleRequest: () async -> Void
        var getOpacity: () -> CGFloat
        var getString: () -> String
    }

    
    static func getRequestString(type: String?, requestStatus: User.RequestStatus?, relationship: UserCore.Relationship?) -> String {
        if type == "sentRequests" {
            return "Pending"
        } else if type == "receivedRequests" {
            return "Accept"
        } else if relationship == .FRIEND {
            return "Unfriend"
        } else if requestStatus == .RECEIVED {
            return "Accept"
        } else if requestStatus == .SENT {
            return "Pending"
        } else {
            return "Send Request"
        }
    }
}

struct TextMessage: Identifiable, Equatable {
    let id: String
    let senderID: String
    let senderName: String
    let messageBody: String
    let sent: Double
    let senderHasImage: Bool
    
    static func == (lhs: TextMessage, rhs: TextMessage) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    init(id: String, senderID: String, senderName: String, messageBody: String, sent: Double, senderHasImage: Bool) {
        self.id = id
        self.senderID = senderID
        self.senderName = senderName
        self.messageBody = messageBody
        self.sent = sent
        self.senderHasImage = senderHasImage
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.senderID = data["senderID"] as? String ?? ""
        self.senderName = data["senderName"] as? String ?? ""
        self.messageBody = data["messageBody"] as? String ?? ""
        self.sent = data["sent"] as? Double ?? 0.0
        self.senderHasImage = data["senderHasImage"] as? Bool ?? true
    }
    
    
}

struct Profile: Codable, ModelEntryPoint {
    var user: User?
    let pastEvents: Feed
    
    static func getParams(otherID: String, otherName: String) -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "otherID": otherID, "time": "past", "otherName": otherName]
    }

    
    func getReferences() -> Set<String> {
        print("get references called")
        var pastFeedRef = pastEvents.getReferences()
        if let user = user {
            if user.core.hasImage {
                pastFeedRef.insert(user.core.userID)
                return pastFeedRef
            } else {
                return pastFeedRef
            }
        } else {
            return pastFeedRef
        }
    }
    
    func checkEmpty() -> Bool {
        return user == nil
    }
    
    struct FunctionHolder {
        var accept: () async -> Void
        var decline: () async -> Void
        var send: () async -> Void
        var unFriend: () async -> Void
    }
}

//struct FriendGroup: Codable, Identifiable {
//    var id: String { return groupID }
//
//    let groupID: String
//    let groupName: String
//    let mostRecentMessage: String
//    let mostRecentMessageDate: Double
//    let numMembers: Int
//    let relationshipToGroup: GroupRelationship
//
//    enum GroupRelationship: String, Codable {
//        case GROUP_MEMBER
//        case GROUP_CREATOR
//        case GROUP_MEMBER_REQUEST
//        case GROUP_MEMBER_REQUEST_DELETED
//    }
//
//    static func interpretRelationship(_ rel: GroupRelationship) -> String {
//        if rel == .GROUP_MEMBER {
//            return "member"
//        } else if rel == .GROUP_CREATOR {
//            return "founder"
//        } else {
//            return "no relationship to group"
//        }
//    }
//
//    static func getParams() -> [String: String] {
//        return ["userID": USER_ID.instance.get()!]
//    }
//}
//
//struct Groups: Codable, ModelEntryPoint {
//    let groups: [FriendGroup]
//
//    func checkEmpty() -> Bool {
//        return groups.count == 0
//    }
//
//    func getReferences() -> Set<String>{
//        return groups.map({ $0.groupID })
//    }
//}
//
//struct GroupProfile: Codable, ModelEntryPoint {
//    let group: FriendGroup?
//    let pastEvents: Feed
//
//    func checkEmpty() -> Bool {
//        return group == nil
//    }
//
//    func getReferences() -> [String] {
//        return [group!.groupID] + pastEvents.getReferences()
//    }
//
//}
