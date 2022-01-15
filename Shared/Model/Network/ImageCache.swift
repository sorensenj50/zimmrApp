//
//  ImageCache.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/3/22.
//

import Foundation
import SwiftUI

//class Cache {
//    static let instance = Cache()
//    private init() { }
//
//    var imageCache: NSCache<NSString, UIImage> = {
//        let cache = NSCache<NSString, UIImage>()
//        cache.countLimit = 100
//        cache.totalCostLimit = 1024 * 1024 * 100 // 100 mb
//        return cache
//    }()
//
//    func addImage(image: UIImage, name: String) {
//        imageCache.setObject(image, forKey: name as NSString)
//    }
//
//    func removeImage(name: String) {
//        imageCache.removeObject(forKey: name as NSString)
//    }
//
//    func getImage(name: String) -> UIImage? {
//        return imageCache.object(forKey: name as NSString)
//    }
//
//    func isInCache(id: String) -> Bool {
//        if let _ = Cache.instance.getImage(name: id) {
//            return true
//        } else {
//            return false
//        }
//    }
//}


class Cache: NSDiscardableContent {
    static let instance = Cache()
    private init() { }

    var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()

    func addImage(image: UIImage, name: String) {
        imageCache.setObject(image, forKey: name as NSString)
    }

    func removeImage(name: String) {
        imageCache.removeObject(forKey: name as NSString)
    }

    func getImage(name: String) -> UIImage? {
        return imageCache.object(forKey: name as NSString)
    }

    func isInCache(id: String) -> Bool {
        if let _ = Cache.instance.getImage(name: id) {
            return true
        } else {
            return false
        }
    }

    func beginContentAccess() -> Bool {
        return true
    }

    func endContentAccess() {

    }

    func discardContentIfPossible() {

    }

    func isContentDiscarded() -> Bool {
        return false
    }
}
