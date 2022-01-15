//
//  Profile_VM.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import Foundation
import SwiftUI

class ProfileViewModel: ViewModel<Profile> {
    
    init(params: [String: String], key: String? = nil) {
        let data = URLData(path: "/user", method: "GET", params: params, body: nil)
        let config = GetConfig(params: params, key: key, timeoutSeconds: 300, postPath: "/userAction")
        let request = GetRequest(data: data, config: config)
        
        super.init(request: request)
    }
    
    func getPostParams(type: String, otherID: String) -> [String: String] {
        return ["type": type, "otherID": otherID, "userID": USER_ID.instance.get()!]
    }
    
    func getFriendParams() -> [String: String] {
        return ["userID": self.request.data.params["userID"]!, "otherID": self.request.data.params["otherID"]!, "type": "friends", "otherName": self.request.data.params["otherName"]!]
    }
    
    func getConnectionsParams() -> [String: String] {
        return ["userID": self.request.data.params["userID"]!, "otherID": self.request.data.params["otherID"]!, "type": "connections", "otherName": self.request.data.params["otherName"]!]
    }
    
    func guardSend() async {
        guard let result = self.result else { return }
        guard let user = result.user else { return }
        
        
        if user.requestStatus == nil {
            let userID = user.core.userID
            let params = getPostParams(type: "sendFriendRequest", otherID: userID)
            self.result!.user!.requestStatus = .SENT
            await self.postRequest(params: params)
        }
    }
    
    func guardAccept() async {
        guard let result = self.result else { return }
        guard let user = result.user else { return }
        
        if user.requestStatus == .RECEIVED {
            let otherID = user.core.userID
            let params = getPostParams(type: "acceptFriendRequest", otherID: otherID)
            await self.postRequest(params: params)
        }
    }
    
    func guardDecline() async {
        guard let result = self.result else { return }
        guard let user = result.user else { return }
        
        if user.requestStatus == .RECEIVED {
            let otherID = user.core.userID
            let params = getPostParams(type: "deleteRequest", otherID: otherID)
            await self.postRequest(params: params, showLoad: true)
        }
    }
    
    func guardUnFriend() async {
        guard let result = self.result else { return }
        guard let user = result.user else { return }
        
        if user.core.relationship == .FRIEND {
            let otherID = user.core.userID
            let params = getPostParams(type: "unFriend", otherID: otherID)
            await self.postRequest(params: params, showLoad: true)
        }
    }
    
    

    

    
    func getString() -> String {
        return User.getRequestString(type: nil, requestStatus: result!.user!.requestStatus, relationship: result!.user!.core.relationship)
    }
    
    func shouldShowButton() -> Bool {
        return result!.user!.core.relationship != .FRIEND && result!.user!.requestStatus != .SENT
    }
    
    func getOpacity() -> CGFloat {
        if result!.user!.requestStatus == .SENT {
            return 0.5
        } else {
            return 1.0
        }
    }
    
    func getFunctions() -> Profile.FunctionHolder {
        return Profile.FunctionHolder(accept: guardAccept, decline: guardDecline, send: guardSend, unFriend: guardUnFriend)
    }
    
    func getName() -> String {
        return result!.user!.core.firstName
    }
    
    func getUserID() -> String {
        return result!.user!.core.userID
    }
}
