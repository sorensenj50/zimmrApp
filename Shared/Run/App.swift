//
//  App.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/3/22.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var model: FirebaseAuthManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @StateObject var rel_tracker = RelationshipTracker()
    @StateObject var message_tracker = NumMessageTracker()
    
    
    var body: some View {
        Group {
            if !networkMonitor.isConnected {
                NoNetworkView()
            } else {
                if model.isSignedInPub && !model.needsSetUp {
                    
                    AppMenu(userID: USER_ID.instance.get()!)
                        .environmentObject(rel_tracker)
                        .environmentObject(message_tracker)
                } else if model.isSignedInPub && model.needsSetUp {
                    NavigationView {
                        SetProfilePage(isFirstCreating: true)
                    }
                    
                } else if !model.isSignedInPub {
                    LandingPage()
                }
            }
        }
        .onAppear {
            model.onAppAppearCheck()
        }
    }
}





