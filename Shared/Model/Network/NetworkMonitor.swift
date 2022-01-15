//
//  NetworkMonitor.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/7/22.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Network Manager")
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        
        monitor.start(queue: queue)
    }
}
