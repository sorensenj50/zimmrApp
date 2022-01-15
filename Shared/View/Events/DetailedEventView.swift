//
//  DetailedEventVIew.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/8/22.
//

import SwiftUI

struct FullScreenEvent: View {
    let data: Event
    let functions: Event.FunctionHolder
    let past: Bool
    @Binding var show: Bool
 
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RelationshipHeader(user: data.core, size: 55)
                .padding(.top, 12)
                .padding(.bottom, 10)
            EventBody(description: data.description)
            Footer(data: data, functions: functions, past: past, isFullScreen: true)
            Divider()
        }
    }
}

struct DetailedEventView: View {
    @EnvironmentObject var tracker: NumMessageTracker
    @StateObject var chatViewModel = ChatViewModel(eventID: EventIDContainer.instance.eventID!, hostID: EventIDContainer.instance.hostID)
    @FocusState var textMode: Bool
    @State var showTopView: Bool = true
    
    var updateMessageNumber: (String, Int) async -> Void
    let data: Event
    let functions: Event.FunctionHolder
    let past: Bool
    
    func onSendFunction(text: String) async {
        let newNumberMessages = chatViewModel.getNumberMessages() + 1
        tracker.message_insert(key: data.eventID, num: newNumberMessages)
        
        await updateMessageNumber(data.eventID, newNumberMessages)
        await chatViewModel.sendMessage(messageBody: text)
    }
    
    func updateWrapper(num: Int) async {
        print("Called Update Wrapper")
        if tracker.update(key: data.eventID, num: num) {
            await updateMessageNumber(data.eventID, num)
        } else {
            print("Didn't send Post Request")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showTopView {
                FullScreenEvent(data: data, functions: functions, past: past, show: $chatViewModel.showEventDetail)
                
            }
            
            ChatView(chatViewModel: chatViewModel, textMode: $textMode, showTopView: $showTopView, updateFunction: updateWrapper)
                .task { await chatViewModel.loadData() }
                
            
            SendMessage(function: onSendFunction)
                .focused($textMode)
        }
        
        .navigationTitle(data.core.firstName + "\'s event")
        .onTapGesture {
            if textMode {
                withAnimation(.linear(duration: 0.2)) {
                    textMode = false
                    showTopView = true
                }
            }
        }
        .onDisappear {
            print("Disappeared")
            chatViewModel.listener?.remove()
        }
    }
}
