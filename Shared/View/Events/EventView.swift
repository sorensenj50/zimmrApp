//
//  EventView.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI



class EventIDContainer {
    var eventID: String? = nil // this can't ever actually be optional but it must start as optional
    var hostID: String? = nil // optional because we might not need to load host's image
    
    static let instance = EventIDContainer()
    private init() {}
}




struct EventView: View {
    static let borderThickNess: CGFloat = 0.5
    static let dateWidth: CGFloat = 90
    
    let data: Event
    let arrayPosition: Event.Position
    let functions: Event.FunctionHolder
    let index: Int
    let past: Bool
    
    @State var isActive = false

    
    private func getBorderThickness() -> (top: CGFloat, bottom: CGFloat) {
        switch arrayPosition {
        case .top:
            return (top: EventView.borderThickNess, bottom: EventView.borderThickNess / 2)
        case .middle:
            return (top: EventView.borderThickNess / 2, bottom: EventView.borderThickNess / 2)
        case .bottom:
            return (top: EventView.borderThickNess / 2, bottom: EventView.borderThickNess)
        case .single:
            return (top: EventView.borderThickNess, bottom: EventView.borderThickNess)
        case .detailed:
            return (top: EventView.borderThickNess, bottom: 0)
        }
    }
    

    var body: some View {
        let (topThick, bottomThick) = getBorderThickness()
        let dateResult = EventDate(unixDate: data.date)
        
        HStack(alignment: .top, spacing: 0.0) {
            DisplayEventDate(dateResult: dateResult)
                .offset(y: 15)
                .frame(width: EventView.dateWidth)
            
            VStack(alignment: .leading, spacing: 0) {
                RelationshipHeader(user: data.core, size: 55)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                EventBody(description: data.description)
                Footer(data: data, functions: functions, past: past, isFullScreen: false)
                
        
                NavigationLink(destination: DetailedEventView(updateMessageNumber: functions.updateNumberMessages!, data: data, functions: functions, past: past),isActive: $isActive) { EmptyView() }
            }
            .overlay(
                Rectangle().frame(height: topThick), alignment: .top)
            .overlay(
                Rectangle().frame(height: bottomThick), alignment: .bottom)
            .overlay(
                Rectangle().frame(width: EventView.borderThickNess), alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            ScrollTracker.instance.didGoToDetailedView()
            EventIDContainer.instance.eventID = data.eventID
            EventIDContainer.instance.hostID = data.core.userID // hostID
            isActive = true
        }
    }
}
