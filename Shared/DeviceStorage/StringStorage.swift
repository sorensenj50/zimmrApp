//
//  zimmerFiveApp.swift
//  Shared
//
//  Created by John Sorensen on 11/19/21.
//




import SwiftUI
import Foundation
import Firebase





class StringStorage {
    var string: String?
    let service: KeychainHelper.Services
    
    init(service: KeychainHelper.Services) {
        self.string = nil
        self.service = service
    }
    
    
    func get() -> String? {
        if let _ = self.string {
            
            
        } else if let string = KeychainHelper.standard.read(service: service) {
            self.string = string
        }
        
        return self.string
    }
    
    func ensureExists(string: String) {
        
        if self.string == nil {
            self.string = string
        }
        
        KeychainHelper.standard.ensureExists(service: self.service, value: string)
    }
    
    func set(string: String)  {
        self.string = string
        KeychainHelper.standard.save(service: self.service, value: string)
    }
    
    func update(string: String) {
        self.string = string
        KeychainHelper.standard.update(service: self.service, newValue: string)
    }
    
    func reset() {
        self.string = nil
    }
    
    func display() {
        print(service.rawValue)
        if let string = self.string {
            print(string)
        } else {
            print("Nil")
        }
    }
    

}


class USER_ID: StringStorage {
    static let instance = USER_ID()
    let AUTH = Auth.auth()
    
    
    private init() {
        super.init(service: .userID)
    }
    

    override func get() -> String? {
        if let _ = self.string {
            
        } else if let currentUser = AUTH.currentUser {
            self.string = currentUser.uid
            
        } else if let userID = KeychainHelper.standard.read(service: .userID) {
            self.string = userID
        }
        
        return self.string
    }
}

class PHONE_NUMBER: StringStorage {
    static let instance = PHONE_NUMBER()
    
    private init() {
        super.init(service: .phoneNumber)
    }
}

class FIRST_NAME: StringStorage {
    static let instance = FIRST_NAME()
    
    private init() {
        super.init(service: .firstName)
    }
}










//class USER_ID_OLD {
//    static let current = USER_ID_OLD()
//    private init() {}
//
//    let AUTH = Auth.auth()
//    var userID: String?
//    var phoneNumber: String?
//    var firstName: String?
//
//    func get() -> String? {
//        if let _ = userID {
//
//        } else if let currentUser = AUTH.currentUser {
//            self.userID = currentUser.uid
//
//        } else if let userID = KeychainHelper.standard.read(service: .userID) {
//            self.userID = userID
//        }
//
//        return self.userID
//    }
//
//    func set(userID: String) {
//        self.userID = userID
//        KeychainHelper.standard.update(service: .userID, newValue: userID)
//    }
//
//    func ensureExists(userID: String) {
//        if self.userID == nil {
//            self.userID = userID
//        }
//
//        KeychainHelper.standard.ensureExists(service: .userID, value: userID)
//    }
//
//    func getPhone() -> String? {
//        if let _ = phoneNumber {
//
//        } else if let currentUser = AUTH.currentUser {
//            self.phoneNumber = currentUser.phoneNumber
//
//        } else if let numberFromStorage = KeychainHelper.standard.read(service: .phoneNumber) {
//            self.phoneNumber = numberFromStorage
//
//        }
//        return self.phoneNumber
//    }
//
//    func setPhone(phoneNumber: String) {
//        self.phoneNumber = phoneNumber
//        KeychainHelper.standard.update(service: .phoneNumber, newValue: phoneNumber)
//    }
//
//    func ensureExists(phoneNumber: String)
//
//
//    func getName() -> String? {
//        if let _ = firstName {
//
//        } else if let firstName = KeychainHelper.standard.read(service: .firstName) {
//            self.firstName = firstName
//        }
//
//        return self.firstName
//    }
//
//
//    func setName(name: String) {
//        self.firstName = name
//        KeychainHelper.standard.update(service: .firstName, newValue: name)
//    }
//
//    func reset() {
//        self.userID = nil
//        self.firstName = nil
//        self.phoneNumber = nil
//    }
//
//    func display() {
//        print("USER_ID")
//
//        if let userID = self.userID {
//            print(userID)
//        } else {
//            print("Nil")
//        }
//
//        if let firstName = self.firstName {
//            print(firstName)
//        } else {
//            print("Nil")
//        }
//
//        if let phoneNumber = self.phoneNumber {
//            print(phoneNumber)
//        } else {
//            print("Nil")
//        }
//    }
//}
//
//


