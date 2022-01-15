//
//  HostEvent.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI
import Combine


struct EventDetails: View {
    @Binding var showAny: Bool
    @Binding var showWhich: String
    @ObservedObject var eventCreator: EventCreator
    
    @FocusState var textFocused: Bool
    
    var body: some View {
        
        VStack {
            HStack {
                Button {
                    showAny = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                }
                
                Spacer()
                
                if !eventCreator.description.isEmpty {
                    Button {
                        showWhich = "Second"
                        
                    } label: {
                        Text("Next")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 5)
            
            
            TitleString(text: "Description")
                .padding(.bottom, 2)
            

            EmptySubtitle(text: "Tell everyone what you're doing!")
                .padding(.bottom, 5)

            DescriptionInput(eventCreator: eventCreator)
                .focused($textFocused)
                .padding(.horizontal, 40)

            TitleString(text: "Date")
                .offset(y: 23)
                .padding(.bottom, 1)

            EmptySubtitle(text: "When's it happening?")
                .offset(y: 23)

            DatePicker("Date", selection: $eventCreator.chosenDate, in: Date()...,  displayedComponents: [.hourAndMinute, .date])
                .datePickerStyle(.compact)
                .frame(width: 100)
            
            
            Spacer()
        }
    }
}


struct Invites: View {
    
    @Binding var showAny: Bool
    @Binding var showWhich: String
    @ObservedObject var eventCreator: EventCreator
    var function: (Bool, URLRequest, Bool) async -> Void

    @StateObject var friendsToggler = InviteToggler(params: InviteToggler.getParams(type: "friends"))
    @StateObject var connectionsToggler = InviteToggler(params: InviteToggler.getParams(type: "connections"))
    

    @State var pickerSelection: String = "Friends"
    
    func submit() async {
        showAny = false
        showWhich = "First"
        
        print("Submitting Host Event Post Request")
        
        let req = eventCreator.getReq(friendsToggler: friendsToggler, connectionsToggler: connectionsToggler)
        await function(true, req, false)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                
                Button {
                    showWhich = "First"
                    
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25))
                }

                Spacer()
                
                if !friendsToggler.isLoading {
                    Button {
                        Task { await submit() }
                    } label: {
                        Text("Submit")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 5)
            
            TitleString(text: "Invitations")
                
            Spacer()
            
            
            VStack {
                EmptySubtitle(text: "Choose who's invited to your event!")
                EmptySubtitle(text: "Tap on each checkmark to toggle")
            }
                .padding(.bottom, 30)
            
        
    
            
            ContentSelector(labels: ["Friends", "Connections"], selected: $pickerSelection)

            if pickerSelection == "Friends" {
                UserListView(viewModel: friendsToggler, functions: friendsToggler.getFunctions())
                    .task { await friendsToggler.loadDataWrapper() }
                    .ignoresSafeArea()
                    .background(friendsToggler.isLoading ? .clear: Color.white)



            } else {
                UserListView(viewModel: connectionsToggler, functions: connectionsToggler.getFunctions())
                    .task { await connectionsToggler.loadDataWrapper() }
                    .ignoresSafeArea()
                    .background(connectionsToggler.isLoading ? .clear: Color.white)
            }
        }
    }
}

struct DescriptionInput: View {
    let placeholder: String = "Description..."

    @ObservedObject var eventCreator: EventCreator

    init(eventCreator: EventCreator) {
        self.eventCreator = eventCreator
        UITextView.appearance().backgroundColor = .clear
    }




    var body: some View {

        HStack(alignment: .bottom) {
            ZStack(alignment: .leading) {
                TextEditor(text: $eventCreator.description)
                    .frame(height: 100)
                    .cornerRadius(6.0)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)


                VStack {
                    Text(eventCreator.description.isEmpty ? placeholder: "")
                        .allowsHitTesting(false)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        .padding(.leading, 2)

                    Spacer()
                }
                .frame(height: 100)

            }
        }
        .padding(10)
        .background(COLORS.GRAY)
        .cornerRadius(30)
    }
}

struct InviteButton: View {
    let index: Int
    let modelFunctions: UserList.FunctionHolder
    
    var body: some View {
        Button {
            print("Toggled")
            Task { await modelFunctions.toggleInvite!(index) }
           
        } label: {
            Group {
                if modelFunctions.isInvited!(index) {
                    HStack {
                        Text("Invited")
                            .foregroundColor(COLORS.SECONDARY)
                        CheckmarkCircle(size: 26)
                    }
                    
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 26, weight: .thin))
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, 20)
        }
    }
}
