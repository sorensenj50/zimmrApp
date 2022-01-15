//
//  ChatVi.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/8/22.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @FocusState.Binding var textMode: Bool
    @Binding var showTopView: Bool
    var updateFunction: (Int) async -> Void
    
    private func shouldShowDate(index: Int) -> Bool {
        if index < chatViewModel.messages.count - 2 { // - 2 because I also need to access the next date
            let thisDate = chatViewModel.messages[index].sent
            let nextDate = chatViewModel.messages[index + 1].sent
            return nextDate - thisDate > numberOfSecondsIn6Hours
        } else {
            return false
        }
        
    }
    
    func getLastIndex() -> Int {
        return chatViewModel.messages.count - 1
    }
    
    
    var body: some View {
        ZStack {
            if chatViewModel.isLoading {
                LoadingView()
            }
            
            if !chatViewModel.messages.isEmpty {
                ScrollView {
                    ScrollViewReader { value in
                        ForEach(0..<chatViewModel.messages.count, id: \.self) { index in
                            if let message = chatViewModel.messages[index] {
                                MessageView(message: message)
                                            .padding(.top, 12)
                                            .padding(.bottom, 1)
                                
                                if shouldShowDate(index: index) {
                                    ChatDateString(date: message.sent)

                                }
                            }
                            
        //                                        .padding(.bottom, message == chatViewModel.messages.last! && textMode ? 30: 0)
                            }
                            .onAppear {
                                value.scrollTo(getLastIndex(), anchor: .bottom)
                                Task { await updateFunction(chatViewModel.getNumberMessages()) }
                            }
                        
                            .onChange(of: chatViewModel.messages) { _ in
                                value.scrollTo(getLastIndex(), anchor: .bottom)
                            }
                        
                            .onChange(of: textMode) { _ in
                                if textMode {
                                    showTopView = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    withAnimation(.linear(duration: 0.1)) {
                                        value.scrollTo(getLastIndex(), anchor: .bottom)
                                    }
                                }
                            }
                        }
                }
            } else if chatViewModel.isLoading {
            
            } else {
                EmptyViewDecider(emptyType: .eventMessage)
                    .onChange(of: textMode) { _ in
                        if textMode {
                            showTopView = false
                        }
                    }
            }
        }
    }
}

struct MessageView: View {
    let message: TextMessage
    
    var body: some View {
        HStack(alignment: .top) {
            NavigationLink {
                ProfileWrapper(params: Profile.getParams(otherID: message.senderID, otherName: message.senderName))
            } label: {
                UserImageDecider(imageID: message.senderID, size: 40)
                    .padding(.leading, 12)
            }
            
        
            VStack(alignment: .leading, spacing: 0) {
                Text(message.senderName)
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                Text(message.messageBody)
                    .font(.system(size: 17))
            }
            Spacer(minLength: 0)
        }
        .padding(.trailing, 40)
    }
}

struct SendMessage: View {
    var function: (String) async -> Void
    
    init(function: @escaping (String) async -> Void) {
        UITextView.appearance().backgroundColor = .clear
        
        self.function = function
    }
    
    
    @State var text: String = ""
    let placeholder = "Message..."
    var body: some View {
        HStack(alignment: .bottom) {
            ZStack(alignment: .leading) {
                TextEditor(text: $text)
                    .frame(minHeight: 35, alignment: .leading)
//                    .cornerRadius(6.0)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color.init(white: 0.9))

                Text(text.isEmpty ? placeholder: "")
                    .allowsHitTesting(false)
                    .foregroundColor(.gray)
                    .padding(.leading, 2)
            }

            Button {
                let toSend = text
                text = ""
                Task { await function(toSend) }
            } label: {
                if !text.isEmpty {
                    Text("Send")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(COLORS.SECONDARY)
                }
            }
            .padding(.trailing, 5)
            .padding(.bottom, 5)
        }
        .padding(10)
        .background(Color.init(white: 0.9))
        .cornerRadius(30)
        .padding()
    }
}


struct ChatDateString: View {
    let dateString: String
    
    init(date: Double) { self.dateString = parseChatDate(unixDate: date) }
    
    
    var body: some View {
        Text(dateString)
            .font(.system(size: 14, weight: .light))
        
    }
}
