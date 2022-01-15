//
//  EventCreation_VM.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/7/22.
//

import Foundation

class EventCreator: ObservableObject  {
    @Published var description: String = ""
    @Published var chosenDate: Date = getTomorrowsDate()
    
    
    func limitText() {
        if description.count > 200 {
            description = String(description.prefix(200))
        }
    }
    
    func getReq(friendsToggler: InviteToggler, connectionsToggler: InviteToggler) -> URLRequest {
        var params = Feed.newEventParams()
        
        if !connectionsToggler.wasLoaded {
            params["connectionsNotLoaded"] = "true"
        } else {
            params["connectionsNotLoaded"] = "false"
        }
        
        if !friendsToggler.wasLoaded {
            params["friendsNotLoaded"] = "true"
        } else {
            params["friendsNotLoaded"] = "false"
        }
        
        let finalInvites = friendsToggler.getInviteList() + connectionsToggler.getInviteList()
        
        print("Invites")
        print(finalInvites)
        print(params)
        
        let body: [String: Any] = ["invited": finalInvites,
                                   "description": description,
                                   "unixDate": chosenDate.timeIntervalSince1970]
        
        
        
        clearVars()
        
        let data = URLData(path: "/host", method: "POST", params: params, body: body)
        return PostRequest(data: data, overrideGetKey: nil).req
    }
    
    private func clearVars() {
        DispatchQueue.main.async {
            self.description = ""
        }
    }
}

class InviteToggler: UserListViewModel {
    var wasLoaded: Bool = false
    
    @Published var allSelected: Bool = true
    @Published var overriden: Bool = false
    @Published var exceptions = Set<Int>()

    init(params: [String: String]) {
        super.init(params: params)
    }
    
    func loadDataWrapper() async {
        self.wasLoaded = true
        await super.loadData()
    }

    
    override func getFunctions() -> UserList.FunctionHolder {
        return UserList.FunctionHolder(type: .hostEvent, toggleInvite: toggleInvite, isInvited: isInvited)
    }
    
    func getInviteList() -> [String] {
        var finalInvites = [String]()
        
        if let result = self.result {
            for index in 0..<result.users.count {
                if isInvited(index: index) {
                    finalInvites.append(result.users[index].userID)
                }
            }
        }
        return finalInvites
    }
    
    func getRelationship(index: Int) -> UserCore.Relationship? {
        return result!.users[index].relationship
    }
    
    func isInvited(index: Int) -> Bool {
        if !overriden {
            return allSelected
        } else {
            if allSelected {
                return !exceptions.contains(index)
            } else {
                return exceptions.contains(index)
            }
        }
    }
    
    func toggleInvite(index: Int) {
        if exceptions.contains(index) {
            exceptions.remove(index)
        } else {
            exceptions.insert(index)
            overriden = true
        }
    }
    
    static func getParams(type: String) -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "otherID": USER_ID.instance.get()!, "type": type]
    }
}
