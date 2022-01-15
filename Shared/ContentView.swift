//
//  ContentView.swift
//  Shared
//
//  Created by John Sorensen on 11/19/21.

import Foundation
//
//  LandingPage.swift
//  zimmerTwo
//
//  Created by John Sorensen on 11/6/21.
//
import SwiftUI




struct Colors {
    var PRIMARY = Color.blue
    var SECONDARY = Color.green
}

let COLORS = Colors()


struct Logo: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 255, height: 255)
            .overlay(
                Hex()
                    .padding()
                    .font(.system(size: 190, weight: Font.Weight.medium))
                    .foregroundColor(.white))
            .cornerRadius(50)
    }
}

struct Hex: View {
    var body: some View {
        Image(systemName: "hexagon")
            .rotationEffect(Angle(degrees: 90.0))
            
    }
}

