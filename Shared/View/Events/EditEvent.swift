//
//  EditEvent.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/18/22.
//

import Foundation
import SwiftUI

// event options

struct EventOptions: View {
    @Binding var inviteMore: Bool
    @Binding var changeEventTime: Bool
    var body: some View {

        Menu {
            Button {
                changeEventTime = true
            } label: {
                Text("Change Event Time")
            }
            
            Button {
                inviteMore = true
            } label: {
                Text("Invite More People")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
}







// change event time


struct ChangeEventTime: View {
    var body: some View {
        VStack {
            Text("Change Time")
        }
    }
}

struct InviteMorePeople: View {
    @State var pickerSelection: String = "Already Invited"
    @State var alreadyInvitedToggler = InviteToggler(params: InviteToggler.getParams(type: "alreadyInvited"))
    @State var notInvitedToggler = InviteToggler(params: InviteToggler.getParams(type: "notInvited"))
    
    var body: some View {
        VStack {
            Text("Invite More People")
            
            
            ContentSelector(labels: ["Already Invited", "Not Invited"], selected: $pickerSelection)

            if pickerSelection == "Already Invited" {
                UserListView(viewModel: alreadyInvitedToggler, functions: alreadyInvitedToggler.getFunctions())
                    .task { await alreadyInvitedToggler.loadDataWrapper() }
                    .ignoresSafeArea()
                    .background(alreadyInvitedToggler.isLoading ? .clear: Color.white)



            } else {
                UserListView(viewModel: notInvitedToggler, functions: notInvitedToggler.getFunctions())
                    .task { await notInvitedToggler.loadDataWrapper() }
                    .ignoresSafeArea()
                    .background(notInvitedToggler.isLoading ? .clear: Color.white)
            }
        }
    }
}


// invite more people



