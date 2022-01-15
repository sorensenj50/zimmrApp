//
//  Chat_VM.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/8/22.
//

import Foundation
import FirebaseFirestore


class ChatViewModel: ObservableObject {
    @Published var messages = [TextMessage]()
    @Published var isLoading: Bool = false
    @Published var showEventDetail = true
    
    let eventID: String
    let hostID: String?
    
    var listener: ListenerRegistration?

    
    init(eventID: String, hostID: String?) {
        self.eventID = eventID
        self.hostID = hostID
    }
    
    func getReferences(messages: [TextMessage]) -> Set<String> {
        return Set(messages.filter({ $0.senderHasImage }).map({ $0.senderID }))
    }

    
    func loadData() async  {
        
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        listener = FirebaseStorageManager.instance.getChatReference(eventID: self.eventID).addSnapshotListener { querySnapShot, error in
            if let error = error {
                print("Error!! :\(error)")
                return
            }

            
            var messages = [TextMessage]()
            
            
            querySnapShot?.documents.forEach({ result in
                let data = result.data()
                messages.append(.init(data: data))
            })
            
            
            
            if !messages.isEmpty {
                let _ = ImageFetcher(references: self.getReferences(messages: messages), 
                                     function: self.update,
                                     result: messages)
                
            } else {
                DispatchQueue.main.async {
                    self.messages = [TextMessage]()
                    self.isLoading = false
                }
            }
        }
        
    }
    
    func sendMessage(messageBody: String) async {
        print("Send Message Called")
        
        let messageDict: [String: Any] = ["id": UUID().uuidString,
                                          "senderID": USER_ID.instance.get()!,
                                          "senderName": FIRST_NAME.instance.get()!,
                                          "messageBody": messageBody,
                                          "sent": Date().timeIntervalSince1970]
        
        DispatchQueue.main.async {
            self.messages.append(TextMessage(data: messageDict))
        }
        
    
        FirebaseStorageManager.instance.sendMessageToCollection(collectionID: self.eventID, messageDict: messageDict)
        
        // post request to neo4j
    }
    
    func getNumberMessages() -> Int {
        return self.messages.count
    }
    
    func update(messages: [TextMessage]) {
        self.messages = messages
        self.isLoading = false
    }
    
    static func setUpDemo() async {
        // for "2c462026-0253-44f3-b132-6b4adc2b2e3f"
        
        let m1 = "When do we get back? I have midterms the next morning"
        
        let m1Dict: [String: Any] = ["id": UUID().uuidString,
                                     "senderID": "0emvTgRnOVd4pX8uXR3GKz5BI692",
                                     "senderName": "Alayna",
                                     "messageBody": m1,
                                     "sent": Date().timeIntervalSince1970]
        
        let m2 = "Hopefully not too late haha"
        
        let m2Dict: [String: Any] = ["id": UUID().uuidString,
                                     "senderID": "EDm9IkLMMOSS0FWqZrSO0KmT8I83",
                                     "senderName": "Kennedy",
                                     "messageBody": m2,
                                     "sent": Date().timeIntervalSince1970]
        
        
        // for "cadb8bbd-ae17-4ab4-8004-0e95f2eee65b"
        let m3 = "are we getting a hotel?"
        
        let m3Dict: [String: Any] = ["id": UUID().uuidString,
                                     "senderID": "vO3V2AeV3QVENb9u32kcTLHI5b12",
                                     "senderName": "Veronica",
                                     "messageBody": m3,
                                     "sent": Date().timeIntervalSince1970]
        
        let m4 = "No, I have family up there that we're staying at"
        
        let m4Dict: [String: Any] = ["id": UUID().uuidString,
                                    "senderID": "5yUXG4GXrBY5oBqt9FTRRfG3Dpg1",
                                    "senderName": "Francisco",
                                    "messageBody": m4,
                                    "sent": Date().timeIntervalSince1970]
        
        let m5 = "ok"
        
        let m5Dict: [String: Any] = ["id": UUID().uuidString,
                                    "senderID": "vO3V2AeV3QVENb9u32kcTLHI5b12",
                                    "senderName": "Veronica",
                                    "messageBody": m5,
                                    "sent": Date().timeIntervalSince1970]
        
        let m6 = "We're meeting at the quad, right?"
        
        let m6Dict: [String: Any] = ["id": UUID().uuidString,
                                     "senderID": "ElgdzKR1SqMxnSObn2U7cEFWNBm1",
                                     "senderName": "Elenore",
                                     "messageBody": m6,
                                     "sent": Date().timeIntervalSince1970]
        
        let m7 = "yeah"
        
        let m7Dict: [String: Any] = ["id": UUID().uuidString,
                                     "senderID": "5yUXG4GXrBY5oBqt9FTRRfG3Dpg1",
                                     "senderName": "Francisco",
                                     "messageBody": m7,
                                     "sent": Date().timeIntervalSince1970]
        
        let m8 = "on my way"
        
        let m8Dict: [String: Any] = ["id": UUID().uuidString,
                                    "senderID": "yQ6NHmiY1uTtpomyaO7gxjbti6I3",
                                    "senderName": "Isaac",
                                    "messageBody": m8,
                                    "sent": Date().timeIntervalSince1970]
        
        
        // for "b17f91cf-6ed5-4152-af07-e37ffc7e7672"
        
        let m9 = "how much are tickets?"
        
        let m9Dict: [String: Any] = ["id": UUID().uuidString,
                                     "senderID": "HiB1WdznkKW95PQbnflSW94AVX83",
                                     "senderName": "Hayden",
                                     "messageBody": m9,
                                     "sent": Date().timeIntervalSince1970]
        
        let m10 = "$10. i'll venmo you"
        
        let m10Dict: [String: Any] = ["id": UUID().uuidString,
                                      "senderID": "JToMBft7RnbNRRUCyRfYgLVIb2x1",
                                      "senderName": "Johnny",
                                      "messageBody": m10,
                                      "sent": Date().timeIntervalSince1970]
        
        
        let messageDictArray = [m1Dict, m2Dict, m3Dict, m4Dict, m5Dict, m6Dict, m7Dict, m8Dict, m9Dict, m10Dict]
        
        for index in 0..<messageDictArray.count {
            let info = messageDictArray[index]
            let eventID: String
            
            if index < 2 {
                eventID = "2c462026-0253-44f3-b132-6b4adc2b2e3f"
            } else if index < 8 {
                eventID = "cadb8bbd-ae17-4ab4-8004-0e95f2eee65b"
            } else {
                eventID = "b17f91cf-6ed5-4152-af07-e37ffc7e7672"
            }
            
            
            FirebaseStorageManager.instance.sendMessageToCollection(collectionID: eventID, messageDict: info)
        }
    }
}
