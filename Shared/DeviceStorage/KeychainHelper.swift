//
//  KeychainHelper.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/10/22.
//

import Foundation

final class KeychainHelper {
    enum Services: String {
        case phoneNumber
        case userID
        case firstName
    }
    
    static let account = "Zimmr"
    static let standard = KeychainHelper()
    private init() {}
    
    
    
    
    // Class implementation here...
    
    func save(service: Services, value: String) {
        
        if let decoded = decodeString(item: value) {
            
            // Create query
            let query = [
                kSecValueData: decoded,
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service.rawValue,
                kSecAttrAccount: KeychainHelper.account,
            ] as CFDictionary
            
            // Add data in query to keychain
            let status = SecItemAdd(query, nil)
            
            if status != errSecSuccess {
                // Print out the error
                print("Error: \(status)")
            }
        }
    }
    
    func read(service: Services) -> String? {
        
        let query = [
            kSecAttrService: service.rawValue,
            kSecAttrAccount: KeychainHelper.account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        if let unwrapped = result {
            let encoded = encodeString(item: unwrapped as! Data)
            return encoded
        } else {
            return nil
        }
    }
    
    func delete(service: Services) {
        
        let query = [
            kSecAttrService: service.rawValue,
            kSecAttrAccount: KeychainHelper.account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
    
    func update(service: Services, newValue: String) {
        if let _ = read(service: service) {
            delete(service: service)
            save(service: service, value: newValue)
        } else {
            save(service: service, value: newValue)
        }
    }
    
    func ensureExists(service: Services, value: String) {
        if let _ = read(service: service) {
            return
        } else {
            save(service: service, value: value)
        }
    }
    
    
    
    private func decodeString(item: String) -> Data? {
        do {
            return try JSONEncoder().encode(item)
            
        } catch {
            print("Keychain Decoding error")
            return nil
        }
    }
    
    private func encodeString(item: Data) -> String? {
        
        do {
            return try JSONDecoder().decode(String.self, from: item)
        } catch {
            print("Keychain Encoding Error")
            return nil
        }
    }
    
    func reset() {
        delete(service: .phoneNumber)
        delete(service: .firstName)
        delete(service: .userID)
    }
    
    func display() {
        print("Keychain")
        if let userID = read(service: .userID) {
            print(userID)
        } else {
            print("Nil")
        }
        
        if let firstName = read(service: .firstName) {
            print(firstName)
        } else {
            print("Nil")
        }
        
        if let phoneNumber = read(service: .phoneNumber) {
            print(phoneNumber)
        } else {
            print("Nil")
        }
    }
}
