//
//  Table.swift
//  splitViewApp
//
//  Created by John Cook on 6/16/16.
//  Copyright © 2016 John Cook. All rights reserved.
//

import Foundation
import UIKit

class Table {
    
    // MARK: - Properties
    
    let months:    [String]! // reference
    var unitsSold: [Double]! // reference
    
    var tableItems:        [String]! // all items in "spreadsheet" table
    var tableItemsVisible: [Bool]!   // visible items in "spreadsheet" table

    var updated: Bool!    // flag for update signal
    let COUNT:   Int      // total number of items in table
    
    var recentIntersection: CGPoint!
    
    // MARK: - Initializer
    
    init() {
        months     = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        unitsSold  = [34.0, 54.0, 74.0, 94.0, 114.0, 134.0, 154.0, 174.0, 93.0, 67.0, 54.0, 104.0]
        tableItems = ["Mth\\Wk", "1", "2", "3", "4", "Jan", "7", "8", "9", "10", "Feb", "12", "13", "14", "15", "Mar", "17", "18", "19", "20", "Apr", "22", "23", "24", "25", "May", "27", "28", "29", "30", "Jun", "32", "33", "34", "35", "Jul", "37", "38", "39", "40", "Aug", "42", "43", "44", "45", "Sep", "28", "12", "11", "42", "Oct", "1", "19", "30", "17", "Nov", "6", "4", "15", "29", "Dec", "0", "37", "22", "45", "", "", "","", "", "", "", "", "", "", "", "", "", "", ""]
        updated = false
        COUNT   = tableItems.count
        recentIntersection = CGPoint()
    }
    
    // MARK: - Modification
    
    func zeroOutWeek(index: Int) {
        if (index < 65) {
           unitsSold[(index/5)-1] -= Double(self.tableItems[index])!
        }
        tableItems[index] = "0"
    }
    
    func zeroOutMonth(index: Int) {
        for i in 1...4 {
            self.tableItems[index+i] = "0"
        }
    }
    
    // NOT CURRENTLY USED
    func updateItem(index: Int, amount: Double) {
//        unitsSoldShow()[index] += amount
    }
    
    // MARK: - Retrieval
    
    func totalUnitsShowing() -> Double {
        var result = 0.0
        for i in 0...unitsSoldShow().endIndex-1 {
            result += unitsSoldShow()[i]
        }
        return result
    }
    
    func monthsIndexWithMatchingName(input: String) -> Int {
        for i in 0..<months.count {
            if (months[i] == input) {
                return i
            }
        }
        return -1
    }
    
    func monthsToShow() -> [String] {
        var result: [String] = []
        var index = 5
        while index < 65 {
                result.append(months[(index/5)-1])
        index += 5
        }
        return result
    }
    
    func unitsSoldShow() -> [Double] {
        var result: [Double] = []
        var index = 5
        while index < 61 {
            // for each month, add its total from showing weeks
                result.append(getWeeksTotalForMonth(index))
            // jump to next month in tableItems
            index += 5
        }
        return result
    }
    
    func getWeeksTotalForMonth(index: Int) -> Double {
        var result = 0.0
        for i in 1...4 {
            // for each week, add it to the total
                result += Double(self.tableItems[index+i])!
        }
        return result
    }
}