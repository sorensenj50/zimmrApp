//
//  EventComponents.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI



struct Footer: View {
    let data: Event
    let functions: Event.FunctionHolder
    let past: Bool
    let isFullScreen: Bool
    
    @EnvironmentObject var tracker: NumMessageTracker
    @State var attendIncrement: Int = 0
    @State var isActive: Bool = false
    
    func hasSeenAllMessages() -> Bool {
        
        let trackerNum = tracker.numHasSeen(key: data.eventID)
        if trackerNum > data.numMessagesSeen {
            return trackerNum >= data.numberMessages
        } else {
            return data.numMessagesSeen >= data.numberMessages
        }
    }
    
    func getAbbreviatedAttendInviteString() -> String {
        return "\(data.numInvited) " + "/" + " \(data.numAttending + attendIncrement)"
    }
    
    func getLongAttendInviteString() -> String {
        return "Invited: " + "\(data.numInvited)" + " / " + "Attending: " + "\(data.numAttending)"
    }
    
    
    
    var body: some View {
        HStack(alignment: .center) {
            
            Button {
                ScrollTracker.instance.didGoToDetailedView() // this string is inaccurate but it will still work for our purposes
                isActive = true
            } label: {
                Text(getAbbreviatedAttendInviteString())
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 45, alignment: .leading)
            }
            
//            if isFullScreen {
//
//            } else if hasSeenAllMessages() {
//                MessageIcon()
//            } else {
//                MessageNotificationIcon()
//            }
            
            if hasSeenAllMessages() {
                MessageIcon()
            } else {
                MessageNotificationIcon()
            }
            
            
            
            Spacer()
            
            if past {
                EmptyView()
            } else if data.relationshipToEvent == .HOST {
                Going(isHost: true, isGoing: true, attendIncrement: $attendIncrement, functions: functions, eventID: data.eventID)
            } else if data.relationshipToEvent == .ATTEND {
                Going(isHost: false, isGoing: true, attendIncrement: $attendIncrement, functions: functions, eventID: data.eventID)
            } else if data.relationshipToEvent == .INVITE {
                Going(isHost: false, isGoing: false, attendIncrement: $attendIncrement, functions: functions, eventID: data.eventID)
            }
            
            NavigationLink(destination: DualUserListWrapper(paramsOne: UserList.getParams(otherID: data.eventID, type: "invite"), paramsTwo: UserList.getParams(otherID: data.eventID, type: "attend"), labelOne: "Invited", labelTwo: past ? "Attended": "Attending").navigationTitle("\(data.core.firstName)'s event"), isActive: $isActive) { EmptyView() }
        }
        .padding(.bottom, past ? 10: 0)
        .padding(.leading, 12)
        .padding(.trailing, 25)
    }
}

struct Going: View {
    @Environment(\.presentationMode) var presentationMode
    let isHost: Bool
    @State var isGoing: Bool
    @Binding var attendIncrement: Int
    let functions: Event.FunctionHolder
    let eventID: String
    

    @State private var showAlert = false

    
    var body: some View {
        if isGoing {
            Button {
                if isHost {
                    withAnimation(.linear(duration: 0.2)) {
                        showAlert.toggle()
                    }
                    
                } else {
                    withAnimation(.linear(duration: 0.2)) {
                        isGoing.toggle()
                        attendIncrement = 0
                    }
                    
                    Task { await functions.attend!(eventID) }
                }
                
                
            } label: {
                CheckmarkCircle()
                    .alert("Delete Event?", isPresented: $showAlert, actions: {
                            Button("Cancel", role: .cancel) { }
                            Button("Continue", role: .destructive) {
                                presentationMode.wrappedValue.dismiss()
                                withAnimation(.linear(duration: 0.2)) {
                                    functions.remove!(eventID)
                                }
                                Task { await functions.dismiss!(eventID, .HOST) }
                            }
                    }, message: {
                        Text("If you leave an event you created, it will be deleted")
                    })
                }
            .padding(.bottom, 8)
        } else {
            HStack(spacing: 0) {
                Button {
                    withAnimation(.linear(duration: 0.2)) {
                        isGoing.toggle()
                        attendIncrement = 1
                    }
                    Task { await functions.attend!(eventID) }
                    
                    
                } label: {
                    Checkmark()
                }
                .padding(.trailing, 25)
                
                
                Button {
                    showAlert.toggle()
                } label: {
                    XMark()
                }
            }
            .padding(.bottom, 16)
            .alert("Dismiss Event?", isPresented: $showAlert, actions: {
                        Button("Cancel", role: .cancel) { }
                        Button("Continue", role: .destructive) {
                            presentationMode.wrappedValue.dismiss()
                            withAnimation(.linear(duration: 0.2)) {
                                functions.remove!(eventID)
                            }
                            Task { await functions.dismiss!(eventID, .DISMISS) }
                        }
            }, message: {
                Text("If you dismiss this event, you won't be able to see it again.")
            })
        }
    }
}

struct MessageIcon: View {
    var body: some View {
        Image(systemName: "bubble.left")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.gray)
        
    }
}


struct MessageNotificationIcon: View {
    var body: some View {
        ZStack {
            MessageIcon()
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(.blue)
                        .frame(width: 9, height: 9)
                }
                Spacer()
            }
        }
        .frame(width: 23, height: 23)
    }
}



struct EventBody: View {
    var description: String
    var body: some View {
        Text(description)
            .multilineTextAlignment(.leading)
            .font(.system(size: 19, weight: .regular))
            .padding(.leading, 22)
            .padding(.trailing, 5)
            .padding(.bottom, 10)
    }
}




struct DisplayEventDate: View {
    let dateResult: EventDate
    var body: some View {
        VStack {
            Text(dateResult.weekdayAbbrev + ", " +  dateResult.month)
                .font(.system(size: 13, weight: .light))
            
            Text(dateResult.day)
                .font(.system(size: 24, weight: .light))
            
            Text(dateResult.hourAndMinute)
                .font(.system(size: 13, weight: .light))
            
        }
    }
}

struct TextDivider: View {
    let text: String
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Color.white
                    .frame(width: EventView.dateWidth)
                Rectangle().frame(height: EventView.borderThickNess / 2)
            }
            
            HStack {
                Rectangle().frame(width: 45, height: EventView.borderThickNess)
                    .padding(.trailing, 7)
                Image(systemName: "arrow.down")
                    .font(.system(size: 10))
                Text(text)
                    .padding(.leading, 5)
                    .font(.system(size: 12))
                Rectangle().frame(width: 45, height: EventView.borderThickNess)
                    .padding(.leading, 7)
            }
            .frame(height: 40)
            
            HStack(alignment: .bottom, spacing: 0) {
                Color.white
                    .frame(width: EventView.dateWidth)
                Rectangle().frame(height: EventView.borderThickNess / 2)
            }
        }
    }
}


struct TextDivider_Old: View {
    let text: String
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Color.white
                    .frame(width: 80)
                Rectangle().frame(height: EventView.borderThickNess / 2)
            }
    
            HStack {
                Rectangle().frame(height: 1.0)
                    .opacity(0.5)
                    .padding(.leading, 25)
                Image(systemName: "arrow.down")
                    .font(.system(size: 10))
                Text(text)
                    .padding(.horizontal, 5)
                    .font(.system(size: 10))
                Rectangle().frame(height: 1.0)
                    .padding(.trailing, 25)
                    .opacity(0.5)
            }
            
            HStack(alignment: .bottom, spacing: 0) {
                Color.white
                    .frame(width: 80)
                Rectangle().frame(height: EventView.borderThickNess / 2)
            }
        }
        .frame(height: 70)
        
    }
}

//struct EventOptions: View {
//    @Binding var inviteMore: Bool
//    @Binding var changeEventTime: Bool
//    var body: some View {
//
//        Menu {
//            Button {
//                isActiveOne = true
//            } label: {
//                Text("Invite More People")
//            }
//
//            Button {
//                isActiveTwo = true
//            } label: {
//                Text("Change Event Time")
//            }
//
//        } label: {
//            Image(systemName: "ellipsis")
//        }
//    }
//}

