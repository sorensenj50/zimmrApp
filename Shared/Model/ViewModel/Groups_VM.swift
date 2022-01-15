//
//  Groups_VM.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import Foundation

//class GroupsViewModel: ViewModel<Groups> {
//    
//    init(params: [String: String], key: String? = nil) {
//        super.init(path: "/groups", postPath: "/groupAction", params: params, key: key)
//    }
//    

    
//    func getPostParams(type: String, eventID: String, value: String = "") -> [String: String] {
//        return ["type": type, "eventID": eventID, "userID": USER_ID.current.get()!, "value": value]
//    }
//    
//    func updateNumberMessages(eventID: String, number: Int) async {
//        guard var (event, _) = findEvent(eventID: eventID) else { return }
//        
//        event.numberMessages = number
//    
//        await postRequest(params: getPostParams(type: "sendMessage", eventID: eventID, value: String(number)))
//    }
//    
//    
//    func toggleAttend(eventID: String) async {
//        guard let (event, index) = findEvent(eventID: eventID) else { return }
//        
//        if event.relationshipToEvent == .ATTEND {
//            result!.events[index].relationshipToEvent = .INVITE
//            URLCacheManager.instance.removeFromCache(key: event.eventID + "invite")
//            URLCacheManager.instance.removeFromCache(key: event.eventID + "attend")
//            await postRequest(params: getPostParams(type: "leave", eventID: eventID))
//            
//        } else if event.relationshipToEvent == .INVITE {
//            result!.events[index].relationshipToEvent = .ATTEND
//            URLCacheManager.instance.removeFromCache(key: event.eventID + "invite")
//            URLCacheManager.instance.removeFromCache(key: event.eventID + "attend")
//            await postRequest(params: getPostParams(type: "attend", eventID: eventID))
//        }
//    }
//    
//    func dismissOrCancel(eventID: String, relationship: Event.Relationship) async {
//        if relationship == .HOST {
//            await postRequest(params: getPostParams(type: "cancel", eventID: eventID))
//        } else {
//            await postRequest(params: getPostParams(type: "dismiss", eventID: eventID))
//        }
//    }
//    
//    func removeEvent(eventID: String) {
//        guard let (_, index) = findEvent(eventID: eventID) else { return }
//        result!.events.remove(at: index)
//        print("Removed")
//        
//    }
//    
//    private func findEvent(eventID: String) -> (Event, Int)? {
//        for index in 0..<result!.events.count {
//            let event = result!.events[index]
//            if event.eventID == eventID {
//                return (event, index)
//            }
//        }
//        return nil
//    }
//}
