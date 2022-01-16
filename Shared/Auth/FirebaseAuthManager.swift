//
//  FirebaseHandler.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/3/22.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SwiftUI




func firebaseErrorParser(error: Error) -> String? {
    print(error)
    if let errorCode = AuthErrorCode(rawValue: error._code) {
    
        switch errorCode {
        case .invalidVerificationCode:
            return "Wrong code or phone number!"
        default:
            return "An error occured... "
        }
    } else {
        return nil
    }
}




class FirebaseAuthManager: ObservableObject {
    @Published var isSignedInPub: Bool = false
    @Published var needsSetUp: Bool = true
    
    @Published var phoneNumber: String = ""
    @Published var showPhoneSubmit: Bool = false
    @Published var phoneSuccess: Bool = false
    
    @Published var code: String = ""
    @Published var showCodeSubmit: Bool = false
    @Published var codeSuccess: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var numberWithRegionCode: String = ""
    
    
    
    let AUTH = Auth.auth()
    var isSignedInCompute: Bool { AUTH.currentUser != nil }
    
    var verificationID: String? = nil
    
    func signOut() {
        
        try? AUTH.signOut()
        isSignedInPub = false
        resetVars()
        KeychainHelper.standard.reset()
        USER_ID.instance.reset()
        FIRST_NAME.instance.reset()
        PHONE_NUMBER.instance.reset()
        URLCacheManager.instance.removeAll()
    }
    
    
    func sendMessage() {
        
        let formattedNumber = formatPhoneNumber(self.phoneNumber)
        print(formattedNumber)

         AUTH.settings?.isAppVerificationDisabledForTesting = true // remove in production?
        PhoneAuthProvider.provider().verifyPhoneNumber(formattedNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.errorMessage = firebaseErrorParser(error: error)
                return
            }
            // setting to storage
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.numberWithRegionCode = formattedNumber
            self.phoneSuccess = true
            self.errorMessage = nil
        
        }
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        if let regionExtension = regionDict[Locale.current.regionCode ?? ""] {
            return "+" + regionExtension + phoneNumber
        } else {
            return "+" + phoneNumber
        }
    }
    
    func verifyCode() async {
        self.isLoading = true

        
        // retrieving from storage
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: self.code)
        AUTH.signIn(with: credential) { authResult, error in
            if let error = error {
                self.isLoading = false
                self.errorMessage = firebaseErrorParser(error: error)
                return
            }

            if let userID = self.AUTH.currentUser?.uid {
                USER_ID.instance.set(string: userID)
                PHONE_NUMBER.instance.set(string: self.numberWithRegionCode)
                
                self.errorMessage = nil // need so that dispatch works
                print("Finished")
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Checking")
            if let userID = USER_ID.instance.get() {
                if self.errorMessage == nil {
                    Task { await self.checkIfUserIDExists(userID: userID) }
                }
            }
        }
    }
    
    func checkIfUserIDExists(userID: String) async {
        let req = composeReqCore(path: "/userIDCheck", method: "GET", params: ["userID": userID], cachePolicy: .reloadIgnoringLocalCacheData)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            if let decodedResponse = try? JSONDecoder().decode(ExistenceResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isSignedInPub = true
                    if decodedResponse.exists {
                        self.needsSetUp = false
                        UserDefaults.standard.set("false", forKey: "needsSetUp")
                    } else {
                        self.needsSetUp = true
                        UserDefaults.standard.set("true", forKey: "needsSetUp")
                    }
                }
            }
            
        } catch {
            print("Post Request Invalid data")
        }
    }
    
    func auraProfileCreated() {
        print("Called")
        self.needsSetUp = false
        UserDefaults.standard.set("false", forKey: "needsSetUp")
    }
    
    func resetVars() {
        self.phoneNumber = ""
        self.code = ""
        self.showCodeSubmit = false
        self.showPhoneSubmit = false
        self.phoneSuccess = false
        self.codeSuccess = false
    }
    
    
    func onAppAppearCheck() {
        self.isSignedInPub = self.isSignedInCompute

        
        if let needsSetUp = UserDefaults.standard.string(forKey: "needsSetUp") {
            print(needsSetUp)
            
            if needsSetUp == "true" {
                self.needsSetUp = true
            } else if needsSetUp == "false" {
                self.needsSetUp = false
            } else if needsSetUp == "notYetChecked" {
                self.isSignedInPub = false
            }
        } else {
            self.isSignedInPub = false
            self.needsSetUp = true
        }
        
        print(needsSetUp)
        print(isSignedInPub)
        print(self.isSignedInCompute)
    }
}

