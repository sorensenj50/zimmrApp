//
//  TestMemoryLeak.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/2/22.
//

import Foundation
import SwiftUI
import Firebase
import UIKit
import FirebaseAuth

struct RuntimeConfig {
    static let host: BackendHost = .local
    
    enum BackendHost {
        case cloud
        case local
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var firebaseManager = FirebaseAuthManager()
    @StateObject var networkMonitor = NetworkMonitor()
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(firebaseManager)
                .environmentObject(networkMonitor)

        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ : UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    }
}









