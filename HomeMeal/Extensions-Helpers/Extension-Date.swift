//
//  DateExtension.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

struct DetailedTime {
    var fullDayName: String?
    var dayNameWithThreeCharacter: String?
    var dayNumber:String?
    var fullMonthName: String?
    var monthNameWithThreeCharacter:String?
    var monthNumber:String?
    var year: String?
    var hour: String?
    var minute: String?
    var second: String?
    var dateAndTimeFullString: String?
    
    init(dateString: String, parseChar: Character = "-") {
        let array = dateString.split(separator: parseChar)
        fullDayName = "\(array[0])"
        dayNameWithThreeCharacter = "\(array[1])"
        dayNumber = "\(array[2])"
        fullMonthName = "\(array[3])"
        monthNameWithThreeCharacter = "\(array[4])"
        monthNumber = "\(array[5])"
        year = "\(array[6])"
        hour = "\(array[7])"
        minute = "\(array[8])"
        second = "\(array[9])"
    }
}

extension Date{
    
    static func dateFromCustomString(_ customString: String, givenFormat: String = "dd.MM.yyyy") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = givenFormat
        return dateFormatter.date(from: customString) ?? Date()
    }
    
    static func stringFromDate(date: Date, dateFormattingStyle: String = "dd.MM.yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormattingStyle
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func stringFromDate(dateFormattingStyle: String = "dd.MM.yyyy") -> String {
        let dateFormatter = DateFormatter()
        //let dateFormatter = ISO8601DateFormatter()
        dateFormatter.dateFormat = dateFormattingStyle
        //Note that the date formatter defaults to showing the date in the user's current timezone. If you want the result to appear in a specific timezone, you need to set the timeZone property of the date formatter
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

extension TimeInterval {
    
    func getDetailedTime(dateStyle: DateFormatter.Style = .long, timeStyle:DateFormatter.Style = .medium ) -> DetailedTime? {
        let date = Date(timeIntervalSince1970: self)
        let formattingStyle = "EEEE-E-dd-MMMM-MMM-MM-yyyy-HH-mm-ss"
        let str = Date.stringFromDate(date: date, dateFormattingStyle: formattingStyle)
        var obj = DetailedTime(dateString: str)
        let dateAndTimeFullString = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .medium)
        obj.dateAndTimeFullString = dateAndTimeFullString
        return obj
    }
    
    func getDayHourMinuteAndSecondAsInt() -> (Int,Int,Int,Int){
        let dayCount = Int(self / 86400)
        let hourCount = Int((self.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minuteCount = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        let secondCount = Int(self.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
        return (dayCount,hourCount,minuteCount,secondCount)
    }
    
    func convertTimeIntervalAsCountTimeString() -> String{
        let dayCount = Int(self / 86400)
        let hourCount = Int((self.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minuteCount = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        let secondCount = Int(self.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
        if dayCount == 0 {
            return String(format: "%02d:%02d:%02d", hourCount, minuteCount, secondCount)
        }else{
            return String(format: "%d \("Day".getLocalizedString()) %02d:%02d:%02d", dayCount, hourCount, minuteCount, secondCount)
        }
    }
    
    static func detailedTimeFromTimeInterval(timeInterval: TimeInterval, dateStyle: DateFormatter.Style = .long, timeStyle:DateFormatter.Style = .medium ) -> DetailedTime? {
        let date = Date(timeIntervalSince1970: timeInterval)
        let formattingStyle = "EEEE-E-dd-MMMM-MMM-MM-yyyy-HH-mm-ss"
        let str = Date.stringFromDate(date: date, dateFormattingStyle: formattingStyle)
        var obj = DetailedTime(dateString: str)
        let dateAndTimeFullString = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .medium)
        obj.dateAndTimeFullString = dateAndTimeFullString
        return obj
    }
}
