//
//  Super.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import Foundation

class ViewModel<T: Codable & ModelEntryPoint>: ObservableObject {
    @Published var result: T?
    @Published var isLoading: Bool = false
    
    let request: GetRequest

    init(request: GetRequest) {
        self.request = request
    }
    
    
    func shouldLoad(manualOverride: Bool = false) -> (Bool, Bool) {
        
        let noResult = self.result == nil
        let oldCache = !URLCacheManager.instance.cacheStillValid(key: self.request.config.key)
        let programOverride = URLCacheManager.instance.hasBeenOverrided(key: self.request.config.key)
        
        let shouldLoad = noResult || oldCache || programOverride || manualOverride
        let shouldIgnoreCache = programOverride || manualOverride
        return (shouldLoad, shouldIgnoreCache)
        
    }
    
    func singleImageFetch() {
        if let result = self.result {
            let _ = ImageFetcher(references: result.getReferences(), function: enterForegroundResultFunc, result: "Fetched")
        }
    }
    
    func enterForegroundResultFunc(string: String) {
        print(string)
    }
    
    
    func loadData(manualOverride: Bool = false, req: URLRequest? = nil, ensureImage: Bool = false) async {
        
        let (shouldLoad, shouldIgnoreCache) = shouldLoad(manualOverride: manualOverride)
        if !shouldLoad {
            if ensureImage {
                print("Single Image Fetch")
                singleImageFetch()
            } else {
                return
            }
        }
        
        
        var useReq: URLRequest
        if let req = req {
            useReq = req
        } else {
            useReq = self.request.req
        }
        
        if shouldIgnoreCache {
            useReq.cachePolicy = .reloadIgnoringLocalCacheData
        }
        
        DispatchQueue.main.async {
            print("isLoading")
            self.isLoading = true
        }
        
        
        
        
        do {
            let (data, _) = try await URLSession.shared.data(for: useReq)
            if let decodedResponse = try? JSONDecoder().decode(T.self, from: data) {
                DispatchQueue.main.async {
                    print("JSON Decoded")
                    if decodedResponse.checkEmpty() {
                        self.nilUpdate()
                    } else {
                        let _ = ImageFetcher(references: decodedResponse.getReferences(),
                                     function: self.update,
                                     result: decodedResponse)
                    }
                }
            }
        } catch {
            print("loadData error!!!")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func postRequest(params: [String: String], body: [String: Any]? = nil, overrideGetkey: String? = nil, showLoad: Bool = false) async {
        
        let data = URLData(path: self.request.config.postPath!, method: "POST", params: params, body: body)
        let request = PostRequest(data: data, overrideGetKey: overrideGetkey)
        
        if showLoad {
            DispatchQueue.main.async {
                self.isLoading = true
            }
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request.req)
            if let _ = try? JSONDecoder().decode(StatusResponse.self, from: data) {
                URLCacheManager.instance.usedPost(request: request)
                print("Status Response Received")
                if showLoad {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
                
        }
            
        } catch {
            if showLoad {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            print("Post Request Invalid data")
        
        }
    }
    
    func update(result: T) {
        self.result = result
        self.isLoading = false
        URLCacheManager.instance.used(request: self.request)
    }
    
    func nilUpdate() {
        self.result = nil
        self.isLoading = false
        URLCacheManager.instance.used(request: self.request)
    }
    
    func getFunctions() {}

}
