//
//  DateTimeUtil.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/24/22.
//

import Foundation

public struct DateTimeUtils {
        
    private struct Constants {
        static let SERVER_DATE_FORMAT: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
        static let DISPLAY_DATE: String = "MMM d, yyyy"
        static let DISPLAY_HOUR: String = "hh:mm a"
        static let DISPLAY_DATE_HOUR: String = "MMM d, yyyy | hh:mm a"

    }
    
    public static func convertServerStringToDate(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()        
        dateFormatter.dateFormat = Constants.SERVER_DATE_FORMAT
        let date = dateFormatter.date(from: stringDate)
        return date!
    }
    
    public static func convertDateToServerString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.SERVER_DATE_FORMAT
        let date = dateFormatter.string(from: date)
        return date
    }
    
    public static func getStringDateFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DISPLAY_DATE
        return dateFormatter.string(from: date)
    }
    
    public static func getStringHourFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DISPLAY_HOUR
        return dateFormatter.string(from: date)
    }
    
    public static func getStringDateAndHourFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DISPLAY_DATE_HOUR
        return dateFormatter.string(from: date)
    }
}



