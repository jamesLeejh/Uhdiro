//
//  customFunc.swift
//  festival beaconyx
//
//  Created by Beaconyx Corp. on 29/10/2019.
//  Copyright © 2019 Beaconyx Corp. All rights reserved.
//

import Foundation
import UIKit

//20190815 -> 2019.08.15로 변환하는 함수
func datestringJoinDot(dateTime: String) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "yyyyMMdd"
    
    let date: Date = dateFormatter.date(from: dateTime)!
    
    dateFormatter.dateFormat = "yyyy.MM.dd"
    let newDate: String = dateFormatter.string(from: date)
    
    return newDate
}

// HTMl 자르기
func HTMLtoString_info(htmlString: String, replace: String) -> String {
    
    let filteredString = htmlString.replacingOccurrences(of: "<[^>]+>", with: replace, options: .regularExpression, range: nil)
    
    let filteredString2 = filteredString.replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression, range: nil)
    
    return filteredString2
}

// 거리 구하기
func getDistance(startX: Double, startY: Double, endX: Double, endY: Double) -> String{

    let p1Lat = startX
    let p1Lng = startY
    let p2Lat = endY
    let p2Lng = endX

    let thema = p1Lng - p2Lng

    var dist = sin(Deg2Rad(deg: p1Lat)) * sin(Deg2Rad(deg: p2Lat)) + cos(Deg2Rad(deg: p1Lat)) * cos(Deg2Rad(deg: p2Lat)) * cos(Deg2Rad(deg: thema))

    dist = acos(dist)
    dist = Rad2Deg(rad: dist)
    dist = dist * 60 * 1.1515 * 1.609344 // status miles to km

    let kmDist = String(format: "%.1f km", dist)

    return kmDist
}

func Deg2Rad(deg: Double) -> Double { return deg * .pi / 180.0 }
func Rad2Deg(rad: Double) -> Double { return rad * 180.0 / .pi }

// 현재 날짜 구하기
func getToday() -> String {
    let date = Date()
    let dateformatter = DateFormatter()

    dateformatter.dateFormat = "yyyyMMdd"

    let today = dateformatter.string(from: date)
    userprint(output: "Today: \(today)")
    
    return today
}

func getThisWeekend() -> (previousSunday: String, nextMonday: String) {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    
    let previousSunday = Date.today().previous(.sunday)
    let nextMonday = Date.today().next(.monday)
    
    userprint(output: "date boundary : \(previousSunday) ~ \(nextMonday)")
    
    return (formatter.string(from: previousSunday), formatter.string(from: nextMonday))
}


extension Date {

    static func today() -> Date {
        return Date()
    }

    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.next,
                    weekday,
                    considerToday: considerToday)
    }

    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.previous,
                    weekday,
                    considerToday: considerToday)
    }

    func get(_ direction: SearchDirection,
    _ weekDay: Weekday,
    considerToday consider: Bool = false) -> Date {

        let dayName = weekDay.rawValue

        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1

        let calendar = Calendar(identifier: .gregorian)

        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }

        var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
        nextDateComponent.weekday = searchWeekdayIndex

        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)

        return date!
    }

}

// MARK: Helper methods
extension Date {
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }

    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }

    enum SearchDirection {
        case next
        case previous

        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .next:
                return .forward
            case .previous:
                return .backward
            }
        }
    }
}
