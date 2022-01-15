//
//  Search_VM.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/9/22.
//

import Foundation

class SearchViewModel: UserListViewModel {
    @Published var text: String = ""
    
    init() {
        super.init(params: ["userID": USER_ID.instance.get()!, "otherID": USER_ID.instance.get()!, "type": "search"])
    }
    
    func cleanSearchTerm(text: inout String) -> String {
        text = text.trimmingCharacters(in: .whitespaces)
        
        if text.first == "@" {
            text.removeFirst()
            return text
        } else {
            return text
        }
    }
    
    func loadData() async {
        
        var params = self.request.data.params
        params["searchTerm"] = cleanSearchTerm(text: &self.text)
        
        print(params)
        
        
        let request = composeReqCore(path: "/userList", method: "GET", params: params, cachePolicy: .reloadIgnoringLocalCacheData)
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let decodedResponse = try? JSONDecoder().decode(UserList.self, from: data) {
                DispatchQueue.main.async {
                    if decodedResponse.checkEmpty() {
                        self.isLoading = false
                        self.result = UserList(users: [])
                    } else {
                        let _ = ImageFetcher(references: decodedResponse.getReferences(),
                                     function: self.update,
                                     result: decodedResponse)
                    }
                }
            }
        } catch {
            self.isLoading = false
            print("View Model Invalid Data")
        }
    }
    
    override func update(result: UserList) {
        print("Overriden Function")
        self.result = result
        self.isLoading = false
    }
}


