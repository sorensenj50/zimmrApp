//
//  RelationshipTracker.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/9/22.
//

import Foundation

class RelationshipTracker: ObservableObject {
    @Published var friends = Set<String>()
    @Published var sent = Set<String>()
    @Published var deleted = Set<String>()
    
    
    func friend_insert(key: String) {
        self.friends.insert(key)
    }
    
    func isFriend(key: String) -> Bool {
        return self.friends.contains(key)
    }
    
    func sendInsert(key: String) {
        self.sent.insert(key)
    }
    
    func sendCheck(key: String) -> Bool {
        return self.sent.contains(key)
    }
    
    func deletedInsert(key: String) {
        self.deleted.insert(key)
    }
    
    func isDeleted(key: String) -> Bool {
        return deleted.contains(key)
    }
    
}

class NumMessageTracker: ObservableObject {
    @Published var eventMessagesSeen = [String: Int]()
    
    
    func message_insert(key: String, num: Int) {
        self.eventMessagesSeen[key] = num
    }
    
    func numHasSeen(key: String) -> Int {
        if let num = self.eventMessagesSeen[key] {
            return num
        } else {
            return 0
        }
    }
    
    func update(key: String, num: Int) -> Bool {
        if let value = self.eventMessagesSeen[key] {
            if num > value {
                self.eventMessagesSeen[key] = num
                return true
            } else {
                return false
            }
        } else {
            if num > 0 {
                self.eventMessagesSeen[key] = num
                return true
            } else {
                return false
            }
        }
    }
}


class NavLinkTracker: ObservableObject {
    @Published var isActive: Bool = false
    
    func ensureFalse() {
        isActive = false
    }
}
