//
//  RelationshipTracker.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/8/22.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @Binding var showBottomTabBar: Bool
    
    @FocusState var textFocused: Bool
    @StateObject var searchViewModel = SearchViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search...", text: $searchViewModel.text)
                    .submitLabel(.search)
                    .keyboardType(.asciiCapable)
                    .padding()
                    .padding(.horizontal, 20)
                    .background(Color.init(white: 0.9))
                    .focused($textFocused)
                    .onSubmit {
                        print("Submitted")
                        Task { await searchViewModel.loadData() }
                    }
                    .onChange(of: textFocused) { _ in
                        showBottomTabBar.toggle()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.15) {
                                textFocused = true
                        }
                    }
                    
                
                    
            }
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .padding(.leading, 10)
                        .foregroundColor(.gray)
                    Spacer()
                })
            .cornerRadius(30)
            .padding()
            
            
//            UserListView(viewModel: searchViewModel, functions: searchViewModel.getFunctions())
            if searchViewModel.isLoading {
                LoadingView()
            } else if searchViewModel.result != nil {
                Divider()
                UserListCore(users: searchViewModel.result!.users)
            } else {
                EmptyViewDecider(emptyType: .beforeSearch)
            }
        }
        .onTapGesture {
            if textFocused && searchViewModel.result == nil {
                textFocused = false
            }
        }
        .navigationBarHidden(true)
    }
}
