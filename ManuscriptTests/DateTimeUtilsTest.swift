//
//  DateTimeUtilsTest.swift
//  ManuscriptTests
//
//  Created by Tigran Ghazinyan on 6/3/22.
//

import XCTest
import Manuscript

class DateTimeUtilsTest: XCTestCase {

    func testConvertServerStringToDate() {
        let serverString = "2022-03-25T10:00:00.000000Z"
        let date = DateTimeUtils.convertServerStringToDate(stringDate: serverString)
        XCTAssertNotNil(date)
    }
    
    func testGetStringDateFromDate() {
        let marchOne = DateTimeUtils.convertServerStringToDate(stringDate: "2022-03-01T10:00:00.000000Z")
        let displayingString = DateTimeUtils.getStringDateFromDate(date: marchOne)
        XCTAssertEqual("Mar 1, 2022", displayingString)
    }
    
    func testGetStringTimeFromDate() {
        let marchOne = DateTimeUtils.convertServerStringToDate(stringDate: "2022-03-01T10:30:00.000000Z")
        let displayingString = DateTimeUtils.getStringHourFromDate(date: marchOne)
        XCTAssertEqual("02:30 AM", displayingString)
    }
    
    func testGetStringDateAndHourFromDate() {
        let marchOne = DateTimeUtils.convertServerStringToDate(stringDate: "2022-03-01T10:30:00.000000Z")
        let displayingString = DateTimeUtils.getStringDateAndHourFromDate(date: marchOne)
        XCTAssertEqual("Mar 1, 2022 | 02:30 AM", displayingString)
    }
}
