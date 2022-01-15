//
//  DateFunctions.swift
//  zimmerFive (iOS)
//
//  Created by John Sorensen on 1/5/22.
//

import Foundation
import SwiftUI

class EventDate {
    let day: String
    let month: String
    let hourAndMinute: String
    let weekdayAbbrev: String
    
    init(unixDate: Double) {
        let converted = Date(timeIntervalSince1970: unixDate)
        self.day = getStringDay(date: converted)
        self.hourAndMinute = getStringHour(date: converted)
        self.month = getStringMonth(date: converted)
        self.weekdayAbbrev = getStringWeekday(date: converted)
    }
}

func parseChatDate(unixDate: Double) -> String {
    let converted = Date(timeIntervalSince1970: unixDate)
    
    if isToday(unixDate: unixDate) {
        return getStringHour(date: converted)
    } else if isYesterday(unixDate: unixDate) {
        return "Yesterday"
    } else if isThisWeek(unixDate: unixDate) {
        return getStringWeekday(date: converted)
    } else {
        return getAbbreviatedDate(date: converted)
    }
}


func getStringWeekday(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE"
    return dateFormatter.string(from: date)
}

func getStringHour(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.amSymbol = "AM"
    dateFormatter.pmSymbol = "PM"
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter.string(from: date)
}

func getAbbreviatedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M/d/yyyy"
    return dateFormatter.string(from: date)
}


func getStringDay(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d"
    return dateFormatter.string(from: date)
}

func getStringMonth(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM"
    return dateFormatter.string(from: date)
}

func getLastMidnight(today: Date) -> Date {
    return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: today)!
}

func getTwoMidnightsAgo(today: Date) -> Date {
    let lastMidnight = getLastMidnight(today: today)
    let calendar = Calendar.current
    return calendar.date(byAdding: .day, value: -1, to: lastMidnight)!
}

func isToday(unixDate: Double) -> Bool {
    return unixDate > getLastMidnight(today: Date()).timeIntervalSince1970
}

func isYesterday(unixDate: Double) -> Bool {
    return unixDate > getTwoMidnightsAgo(today: Date()).timeIntervalSince1970
}

let numberOfSecondsInSevenDays: Double = 60 * 60 * 24 * 7
let numberOfSecondsIn6Hours: Double = 60 * 60 * 6

func isThisWeek(unixDate: Double) -> Bool {
    return unixDate > (Date().timeIntervalSince1970 - numberOfSecondsInSevenDays)
}

func getCurrenDate() -> Double {
    return Date().timeIntervalSince1970
}

func getEndOfNextWeek() -> Double? {
    return Date().endOfNextWeek?.timeIntervalSince1970
}

func getEndOfWeek() -> Double? {
    return Date().endOfWeek?.timeIntervalSince1970
}

func thisMidnight() -> Double {
    return futureDate(numDaysAhead: 0, hour: 23, minute: 59).timeIntervalSince1970
}

func getTodaysDate() -> Date {
    return futureDate(numDaysAhead: 0, hour: 20, minute: 30)
}

func getTomorrowsDate() -> Date {
    return futureDate(numDaysAhead: 1, hour: 20, minute: 30)
}

func futureDate(numDaysAhead: Int, hour: Int, minute: Int) -> Date {
    let today: Date = Date()
    var noon: Date {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: today)!
        }
    let calendar = Calendar.current
    return calendar.date(byAdding: .day, value: numDaysAhead, to: noon)!
}






//func generateUnixDates() -> [Double] {
//    let current = Date().timeIntervalSince1970
//    var toReturn: [Double] = []
//    for index in 0..<10 {
//        let num = current - Double(index * 100_000)
//        
//        print(index)
//        print(num)
//        
//        let converted = Date(timeIntervalSince1970: num)
//        
//        print(getStringMonth(date: converted))
//        print(getStringWeekday(date: converted))
//        print(getStringDay(date: converted))
//        print(getStringHour(date: converted))
//        
//        
//        toReturn.append(num)
//    }
//    
//    return toReturn
//}

//struct DateFunctionTester: View {
//    let testDates: [Double]
//    init() {
//        self.testDates = generateUnixDates()
//    }
//
//    var body: some View {
//        VStack {
//            ForEach(testDates, id: \.self) { num in
//                let result = parseGroupsRecentMessageDate(unixDate: num)
//
//                Text(result)
//            }
//        }
//    }
//}


//struct previews: PreviewProvider {
//    static var previews: some View {
//        DateFunctionTester()
//    }
//}
