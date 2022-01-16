//
//  DemoImageFetcher.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/15/22.
//

import Foundation
import SwiftUI




class ImageDictionaryContainer {
    static let idDict: [String: String] =
    [
     "wpUU5mrgmvS3fDeh06tmW5zVj2c2": "Screen Shot 2021-12-08 at 6.45.18 PM.png",
     "gX7of1dtKHQwvfP8pFNIP8GuLBy1": "Kennedy.jpg",
     "0emvTgRnOVd4pX8uXR3GKz5BI692": "Alayna.jpg",
     "JToMBft7RnbNRRUCyRfYgLVIb2x1": "Screen Shot 2021-12-06 at 5.12.47 PM.png",
     "c6ktkpL3FNSiJe0Kr458khp46x52": "Eric.jpg",
     "Oy89dGS4hnThrQKbod8234pHbu92": "Screen Shot 2021-12-06 at 5.16.38 PM.png",
     "yQ6NHmiY1uTtpomyaO7gxjbti6I3": "Screen Shot 2021-12-06 at 5.20.05 PM.png",
     "DPto7SQJhFTG6rGXqVRSAkiNoAW2": "28754e095e9e1135aca90abcddf6d1cb.jpeg",
     "slpH4K4TUoRmRaHfVyrfjSe6vgf1": "Screen Shot 2021-12-06 at 5.16.38 PM.png",
     "mtVgA602qKMxqadufxWDxMPWMvo2": "Screen Shot 2021-12-06 at 7.56.45 PM.png",
     "HiB1WdznkKW95PQbnflSW94AVX83": "Screen Shot 2021-12-06 at 8.06.02 PM.png",
     "5yUXG4GXrBY5oBqt9FTRRfG3Dpg1": "Francisco.jpg",
     "jrwsla8CN1VekAw7Yeh4BrXwoTs2": "forrest.jpg",
     "weST5RAFXbfFrwWp1QznOdcTrwh1": "Screen Shot 2021-12-06 at 8.10.48 PM.png",
     "vO3V2AeV3QVENb9u32kcTLHI5b12": "Grace.jpg", // trading veronica and grace
     "tNXtMG4FhTR2MiwJ9bklxocLPs63": "Tyler.jpg",
     "g8FwRdNMa9VSlyoX5y3vFHNpJtJ2": "Veronica.jpg", // trading veronica and grace
     "ZzuxFaOJPpdwlyRCOck0sz54gk23": "a4673315cc0542738628091437daea1a.jpeg",
     "03d10g5SXkV905b7yHhfgN3zIHw2": "Screen Shot 2021-12-07 at 12.29.52 AM.png",
     "ElgdzKR1SqMxnSObn2U7cEFWNBm1": "Elenore.jpg",
     "LjtrUkeNuOZtur5V22m8JsmFp3t1": "Screen Shot 2021-12-07 at 12.40.39 AM.png",
     "F1laATGocCPuXSNADSJVYwNhb8G2": "Screen Shot 2021-12-16 at 10.46.34 AM.png",
     "MgjmgvT2xMO9mN3muKgzDTE8Q302": "Maribel.jpg",
     "TzrpKbhAqUPpm5Z8fZDdHdZMaPz1": "b9207a2a805b37fe863739c14b2e0878.jpeg",
     "2361f93a-7680-43cc-bfbb-a893a1aa567b": "Screen Shot 2021-12-07 at 12.29.52 AM.png",
     "cef4f746-a231-4702-af8d-e2edd38fb4a4": "Screen Shot 2021-12-06 at 8.09.37 PM.png",
     "6e564022-7182-4287-a9a2-8d6780f8df0c": "Screen Shot 2021-12-06 at 5.20.05 PM.png",
    ]
     
}

class ImageFetcher<Result> {
    
    let function: (Result)->Void
    let result: Result
    var numberReady: Int = 0
    var numberNeeded: Int?
    

    init(references: Set<String>, function: @escaping (Result)->Void, result: Result) {
        self.function = function
        self.result = result
        
        print(references.count)
        self.fetchImages(references: references)
        
        
    }

    
    func fetchImages(references: Set<String>) {
        self.numberNeeded = references.count
        if self.numberNeeded == 0 {
            self.function(self.result)
        } else {
            for imageID in references {
                fetchIndividualImage(id: imageID)
            }
        }
    }
    
    func fetchIndividualImage(id: String) {
        var useID = id
        if let newID = ImageDictionaryContainer.idDict[id] {
            useID = newID
        } else {
            
        }
        
        
        if Cache.instance.isInCache(id: id) {
            self.increaseAndCheckReady()
            return
        } else {
            let ref = FirebaseStorageManager.instance.getUploadReference(id: useID)
            ref.getData(maxSize: 2051240) { data, error in
                if error != nil {
                    self.increaseAndCheckReady()
                    return
                }
                let image = UIImage(data: data!)
                Cache.instance.addImage(image: image!, name: id)
                self.increaseAndCheckReady()
            }
        }
    }
    
    func increaseAndCheckReady() {
        self.numberReady += 1
        if self.numberReady == self.numberNeeded {
            self.function(self.result)
        }
    }
}
