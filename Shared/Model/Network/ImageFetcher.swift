//
//  ImageFetcher.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import Foundation
import SwiftUI


//class ImageFetcher<Result> {
//    
//    let function: (Result)->Void
//    let result: Result
//    var numberReady: Int = 0
//    var numberNeeded: Int?
//    
//
//    init(references: Set<String>, function: @escaping (Result)->Void, result: Result) {
//        self.function = function
//        self.result = result
//        
//        print(references.count)
//        self.fetchImages(references: references)
//        
//        
//    }
//
//    
//    func fetchImages(references: Set<String>) {
//        self.numberNeeded = references.count
//        if self.numberNeeded == 0 {
//            self.function(self.result)
//        } else {
//            for imageID in references {
//                fetchIndividualImage(id: imageID)
//            }
//        }
//    }
//    
//    func fetchIndividualImage(id: String) {
//        if Cache.instance.isInCache(id: id) {
//            self.increaseAndCheckReady()
//            return
//        } else {
//            let ref = FirebaseStorageManager.instance.getUploadReference(id: id)
//            ref.getData(maxSize: 2051240) { data, error in
//                if error != nil {
//                    self.increaseAndCheckReady()
//                    return
//                }
//                let image = UIImage(data: data!)
//                Cache.instance.addImage(image: image!, name: id)
//                self.increaseAndCheckReady()
//            }
//        }
//    }
//    
//    func increaseAndCheckReady() {
//        self.numberReady += 1
//        if self.numberReady == self.numberNeeded {
//            self.function(self.result)
//        }
//    }
//}
