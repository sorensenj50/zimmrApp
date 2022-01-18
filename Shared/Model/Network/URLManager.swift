//
//  URLManager.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/4/22.
//

import Foundation

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}


func composeReqCore(path: String, method: String, params: [String: String], body: [String: Any]? = nil, cachePolicy: URLRequest.CachePolicy) -> URLRequest {
    var components = URLComponents()
    
    if RuntimeConfig.host == .local {
        components.scheme = "http"
        components.host = "localhost"
        components.port = 8080
    } else {
        components.scheme = "https"
        components.host = "elite-emitter-337602.wn.r.appspot.com"
        
    }
    
    
        
    components.path = path
    components.setQueryItems(with: params)

    var request = URLRequest(url: components.url!)

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = method
    
    request.cachePolicy = cachePolicy
    
    if let body = body {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        } catch {
            print(error.localizedDescription)
        }
        
    }
    return request
}


func composeReqWrapper(data: URLData, cachePolicy: URLRequest.CachePolicy) -> URLRequest {
    return composeReqCore(path: data.path, method: data.method, params: data.params, body: data.body, cachePolicy: cachePolicy)
}



struct URLData {
    let path: String
    let method: String
    let params: [String: String]
    let body: [String: Any]?
}



struct PostConfig {
    static let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData

    let overrideGetKey: String?
}

struct GetConfig {
    let key: String
    let cachePolicy: URLRequest.CachePolicy
    let timeoutSeconds: Int
    let postPath: String?
    
    static let defaultTimeoutSeconds: Int = 30
    static let defaultCachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    
    static func generateKey(params: [String: String]) -> String {
        return params.map { $0.0 + "=" + $0.1 }.joined(separator: ";")
    }
    
    init(params: [String: String]? = nil, key: String? = nil, cachePolicy: URLRequest.CachePolicy? = nil, timeoutSeconds: Int? = nil, postPath: String? = nil) {
        if let key = key {
            self.key = key
        } else {
            self.key = GetConfig.generateKey(params: params!)
        }
        
        self.cachePolicy = cachePolicy ?? GetConfig.defaultCachePolicy
        self.timeoutSeconds = timeoutSeconds ?? GetConfig.defaultTimeoutSeconds
        self.postPath = postPath
    }
}


class GetRequest {
    let req: URLRequest
    let config: GetConfig
    let data: URLData
    
    init(data: URLData, config: GetConfig) {
        self.data = data
        self.config = config
        self.req = composeReqWrapper(data: data, cachePolicy: config.cachePolicy)
    }
}

class PostRequest {
    let req: URLRequest
    let config: PostConfig
    let data: URLData
    
    init(data: URLData, overrideGetKey: String?) {
        self.data = data
        self.config = PostConfig(overrideGetKey: overrideGetKey)
        self.req = composeReqWrapper(data: data, cachePolicy: PostConfig.cachePolicy)
    }
}


class URLCacheManager {
    static let instance = URLCacheManager()
    private init() {}
    
    
    var reqsDict: [String: URLRequest] = [:]
    var overriden = Set<String>()
    
    func removeFromCache(key: String) {
        if let req = reqsDict[key] {
            print("removing: " + key + " from cache")
            URLCache.shared.removeCachedResponse(for: req)
        }
    }
    
    func used(request: GetRequest) {
        if !reqsDict.keys.contains(request.config.key) {
            self.reqsDict[request.config.key] = request.req
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(request.config.timeoutSeconds)) {
                
                self.removeFromCache(key: request.config.key)
                self.reqsDict.removeValue(forKey: request.config.key)
            }
        }
    }
    
    func cacheStillValid(key: String) -> Bool {
        return reqsDict.keys.contains(key)
    }
    
    func removeAll() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    func overrideReq(key: String) {
        print("Overriding")
        print(key)
        overriden.insert(key)
    }
    
    func hasBeenOverrided(key: String) -> Bool {
        if overriden.contains(key) {
            overriden.remove(key)
            return true
        } else {
            return false
        }
    }
    
    func usedPost(request: PostRequest) {
        if let key = request.config.overrideGetKey {
            overrideReq(key: key)
        }
    }
}
