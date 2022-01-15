//
//  Feed_VM.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import Foundation

class FeedViewModel: ViewModel<Feed> {
    
    init(params: [String: String], key: String? = nil) {
        let data = URLData(path: "/events", method: "GET", params: params, body: nil)
        let config = GetConfig(params: params, key: key, postPath: "/eventAction")
        
        let request = GetRequest(data: data, config: config)
        super.init(request: request)
    }

    
    init(feed: Feed, params: [String: String], key: String? = nil) {
        let data = URLData(path: "/events", method: "GET", params: params, body: nil)
        let config = GetConfig(params: params, key: key, postPath: "/eventAction")
        
        let request = GetRequest(data: data, config: config)
        super.init(request: request)
        super.result = feed
    }
    
    
    func getFunctions() -> Event.FunctionHolder {
        return Event.FunctionHolder(attend: toggleAttend, dismiss: dismissOrCancel, remove: removeEvent, updateNumberMessages: updateNumberMessages)
    }
    
    
    func getNullFunctions() -> Event.FunctionHolder {
        return Event.FunctionHolder(attend: nil, dismiss: nil, remove: nil, updateNumberMessages: updateNumberMessages)
    }
    
    func getPostParams(type: String, eventID: String) -> [String: String] {
        return ["type": type, "eventID": eventID, "userID": USER_ID.instance.get()!]
    }
    
    func getMessageUpdateParams(eventID: String, newNumber: String) -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "type": "updateMessageNumber", "eventID": eventID, "newNumber": newNumber]
    }
    
    func updateNumberMessages(eventID: String, number: Int) async {
        guard var (event, _) = findEvent(eventID: eventID) else { return }
        
        event.numberMessages = number
        print("Sending Update Message Num Post Request")
    
        await postRequest(params: getMessageUpdateParams(eventID: event.eventID, newNumber: String(number)))
    }
    

    
    func toggleAttend(eventID: String) async {
        guard let (event, index) = findEvent(eventID: eventID) else { return }
        
        if event.relationshipToEvent == .ATTEND { // not sure about the idea of checking... feed feels detached from state of lower components and database
            result!.events[index].relationshipToEvent = .INVITE
            URLCacheManager.instance.overrideReq(key: event.eventID + "attend")
            await postRequest(params: getPostParams(type: "leave", eventID: eventID))
            
        } else if event.relationshipToEvent == .INVITE {
            result!.events[index].relationshipToEvent = .ATTEND
            URLCacheManager.instance.overrideReq(key: event.eventID + "attend")
            await postRequest(params: getPostParams(type: "attend", eventID: eventID))
        }
    }
    
    func dismissOrCancel(eventID: String, relationship: Event.Relationship) async {
        if relationship == .HOST {
            await postRequest(params: getPostParams(type: "cancel", eventID: eventID))
        } else {
            await postRequest(params: getPostParams(type: "dismiss", eventID: eventID))
        }
    }
    
    func removeEvent(eventID: String) {
        guard let (_, index) = findEvent(eventID: eventID) else { return }
        result!.events.remove(at: index)
    
    }
    
    private func findEvent(eventID: String) -> (Event, Int)? {
        for index in 0..<result!.events.count {
            let event = result!.events[index]
            if event.eventID == eventID {
                return (event, index)
            }
        }
        return nil
    }
}
