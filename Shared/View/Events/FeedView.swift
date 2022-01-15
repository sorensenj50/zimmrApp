//
//  FeedView.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI

struct FutureFeedViewer: View {
    @ObservedObject var feedViewModel: FeedViewModel
    @Binding var eventCreationIsActive: Bool
    
    var body: some View {
        if feedViewModel.isLoading {
            LoadingView()
        } else if feedViewModel.result != nil && !feedViewModel.result!.checkEmpty() {
            FeedViewCore(events: feedViewModel.result!.events, functions: feedViewModel.getFunctions(), time: feedViewModel.request.data.params["time"]!)
                .onAppear {
                    if let firstName = feedViewModel.result!.firstName {
                        FIRST_NAME.instance.ensureExists(string: firstName)
                    }
                }
               
        } else if !feedViewModel.isLoading {
            EmptyContentViewButtonWrapper(title: "No Events", subTitle: "Events that you're invited to or hosting will show up here", imageName: "note.text", buttonShow: $eventCreationIsActive)
        }
    }
}

struct FeedViewer: View {
    @ObservedObject var feedViewModel: FeedViewModel
    
    var body: some View {
        if feedViewModel.isLoading {
            LoadingView()
        } else if feedViewModel.result != nil && !feedViewModel.result!.checkEmpty() {
            FeedViewCore(events: feedViewModel.result!.events, functions: feedViewModel.getFunctions(), time: feedViewModel.request.data.params["time"]!)
                .onAppear {
                    if let firstName = feedViewModel.result!.firstName {
                        FIRST_NAME.instance.ensureExists(string: firstName)
                    }
                }
               
        } else if !feedViewModel.isLoading {
            EmptyViewDecider(feedParams: feedViewModel.request.data.params)
        }
    }
}




struct FeedViewWrapper: View {
    let params: [String: String]
    let key: String?
    
    init(params: [String: String], key: String? = nil) {
        self.params = params
        self.key = key
    }
    
    var body: some View {
        let feedViewModel = FeedViewModel(params: params, key: key)
        FeedViewer(feedViewModel: feedViewModel).task { await feedViewModel.loadData() }
    }
}


struct FeedViewCore: View {
    let events: [Event]
    let functions: Event.FunctionHolder
    let time: String
    
    let endOfDay: Double
    
    init(events: [Event], functions: Event.FunctionHolder, time: String) {
        self.events = events
        self.functions = functions
        self.time = time
        
        self.endOfDay = thisMidnight()

    }
    
    private func placeTextDivider(index: Int, date: Double) -> String? {
        if index >= events.count - 1 {
            return nil
        } else {
            let nextDate = events[index + 1].date
            
            if date > endOfDay && nextDate < endOfDay {
                return "Today"
            } else {
                return nil
            }
        }
    }
    
    private func mapPosition(index: Int, willHaveDivider: Bool) -> Event.Position {
        if events.count == 1 {
            return .single
        } else if index == 0 {
            return .top
        } else if index == events.count - 1 {
            return .bottom
        } else {
            return .middle
        }
    }
    
    private func getScrollPosition() -> Int {
        if time == "future" {
            return events.count - 1
        } else {
            return 0
        }
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                let count = events.count
                VStack(spacing: 0) {
                    ForEach(0..<count, id: \.self) { index in
                        VStack(spacing: 0) {
                            let event = events[index]

                            let text = placeTextDivider(index: index, date: event.date)
                            
                            EventView(data: event, arrayPosition: mapPosition(index: index, willHaveDivider: text != nil), functions: functions, index: index, past: time == "past")
                            
                            if let text = text {
                                TextDivider(text: text)
                            }
                            
                            if index == count - 1 {
                                Color.white.frame(height: 30)
                            }

                        }
                    }
                }
                .onAppear {
                    if ScrollTracker.instance.shouldScrollToBottom() {
                        value.scrollTo(getScrollPosition(), anchor: .bottom)
                    }
                }
            }
        }
    }
}

class ScrollTracker {
    static let instance = ScrollTracker()
    private init() {}
    var destination: String? = nil
    
    func shouldScrollToBottom() -> Bool {
        if destination != "detailedEventView" {
            destination = nil
            return true
        } else {
            destination = nil
            return false
        }
    }
    
    func didGoToDetailedView() {
        print("Did set ScrollTracker detailed")
        self.destination = "detailedEventView"
    }
}
