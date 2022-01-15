//
//  FirebaseStorageManager.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import Foundation
import Firebase


class FirebaseStorageManager {
    static let instance = FirebaseStorageManager()
    private init() {}
    
    let STORAGE = Storage.storage()
    let FIRESTORE = Firestore.firestore()
    
    func getUploadReference(id: String) -> StorageReference {
        return STORAGE.reference(withPath: id)
    }
    
    func getDownloadReference(id: String) -> StorageReference {
        return STORAGE.reference().child(id)
    }
    
    func sendMessageToCollection(collectionID: String, messageDict: [String: Any]) {
        print("\n")
        print("Sending Message")
        
        let path = FIRESTORE
            .collection("eventchats")
            .document("Document")
            .collection(collectionID)
            .document(messageDict["id"] as! String)
        
       
        
        path.setData(messageDict) { error in
            if let _ = error {
                print("Failed to Save Message: ")
            }
            
            print("Succes!")
        }
    }
    
    func getChatReference(eventID: String) -> Query {
        return FIRESTORE
            .collection("eventchats")
            .document("Document")
            .collection(eventID)
            .order(by: "sent")
    }
}
    
