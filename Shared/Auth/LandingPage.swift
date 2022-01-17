//
//  LandingPage.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/3/22.
//

import SwiftUI

struct LandingPage: View {
    @EnvironmentObject var firebaseAuthManager: FirebaseAuthManager
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack {

                    Logo()
                        .frame(width: geo.size.width - 130, height: geo.size.width - 130)
                        .padding(.top, 20)
            
                    TitleString(text: "Welcome to Zimmr!", size: 25)
                        .padding(.top, 10)
                    
                    EmptySubtitle(text: "We're the app that helps you organize fun activities and expand your friend group!")
                        .padding(.horizontal)
                        .padding(.top, 5)
                
                        
                    Spacer()

                    NavigationLink(destination: EnterPhone(isCreatingAccount: true)) {
                        AuthRectangle(string: "Create Profile", color: COLORS.PRIMARY)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 10)
                    }
                        
                    NavigationLink(destination: EnterPhone(isCreatingAccount: false)) {
                        AuthRectangle(string: "Login", color: COLORS.SECONDARY)
                            .padding(.horizontal, 30)
                    }

                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                
            }
        }
    }
}

struct Logo: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [COLORS.PRIMARY, COLORS.SECONDARY]), startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "hexagon")
                .resizable()
                .scaledToFit()
                .rotationEffect(Angle(degrees: 90))
                .foregroundColor(.white)
                .padding(20)
            
        }
        .cornerRadius(40)
    }
}





