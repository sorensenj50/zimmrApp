//
//  UserList_VM.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/7/22.
//

import Foundation

class UserListViewModel: ViewModel<UserList> {
    
    init(params: [String: String], key: String? = nil, timeoutseconds: Int? = nil) {
        let data = URLData(path: "/userList", method: "GET", params: params, body: nil)
        let config = GetConfig(params: params, key: key, timeoutSeconds: timeoutseconds, postPath: "/userAction")
        let request = GetRequest(data: data, config: config)
        
        
        
        super.init(request: request)
    }

    
    func getPostParams(type: String, otherID: String) -> [String: String] {
        return ["type": type, "otherID": otherID, "userID": USER_ID.instance.get()!]
    }
    
    private func getUser(index: Int) -> UserCore {
        return result!.users[index]
    }
    
    
    func acceptFriendRequest(index: Int) async {
        let user = getUser(index: index)
        URLCacheManager.instance.overrideReq(key: "friends")
        await postRequest(params: getPostParams(type: "acceptFriendRequest", otherID: user.userID))
    }
    
    func deleteFriendRequest(index: Int) async {
        let user = getUser(index: index)
        await postRequest(params: getPostParams(type: "deleteRequest", otherID: user.userID))
    }
    
    
    func getFunctions() -> UserList.FunctionHolder? {
        if request.data.params["type"] == "receivedRequests" {
            return UserList.FunctionHolder(type: .requests, accept: acceptFriendRequest, delete: deleteFriendRequest)
        } else {
            return nil
        }
    }
}
