//
//  Table.swift
//  splitViewApp
//
//  Created by John Cook on 6/16/16.
//  Copyright © 2016 John Cook. All rights reserved.
//

import Foundation

class Table {
    
    // MARK: - VARIABLES
    
    let months:    [String]! // reference
    var unitsSold: [Double]! // reference
    
    var tableItems:        [String]! // all items in "spreadsheet" table
    var tableItemsVisible: [Bool]!   // visible items in "spreadsheet" table

    var updated: Bool!    // flag for update signal
    let COUNT:   Int      // total number of items in table
    
    // MARK: - INITIALIZER
    
    init() {
        months        = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        unitsSold     = [34.0, 54.0, 74.0, 94.0, 114.0, 134.0, 154.0, 174.0, 93.0, 67.0, 54.0, 104.0]
        tableItems = ["Mth\\Wk", "1", "2", "3", "4", "Jan", "7", "8", "9", "10", "Feb", "12", "13", "14", "15", "Mar", "17", "18", "19", "20", "Apr", "22", "23", "24", "25", "May", "27", "28", "29", "30", "Jun", "32", "33", "34", "35", "Jul", "37", "38", "39", "40", "Aug", "42", "43", "44", "45", "Sep", "28", "12", "11", "42", "Oct", "1", "19", "30", "17", "Nov", "6", "4", "15", "29", "Dec", "0", "37", "22", "45", "", "", "","", ""]
        tableItemsVisible = []
        for _ in 0..<tableItems.count {
            tableItemsVisible.append(true)
        }
        updated    = false
        COUNT = tableItems.count
    }
    
    // MARK: - FUNCTIONS
    
    func activate(index: Int) {
        self.tableItemsVisible[index] = true
        // if index is a month
        if (index > 4 && index % 5 == 0) {
            for i in 1...4 {
                self.tableItemsVisible[index+i] = true
            }
        }
            // if index is a week
        else {
            unitsSold[(index/5)-1] += Double(self.tableItems[index])!
        }
    }
    
    func deactivate(index: Int) {
        self.tableItemsVisible[index] = false
        // if index is a month
        if (index > 4 && index % 5 == 0) {
            for i in 1...4 {
                self.tableItemsVisible[index+i] = false
            }
        }
        // if index is a week
        else {
            unitsSold[(index/5)-1] -= Double(self.tableItems[index])!
        }
    }
    
    func updateItem(index: Int, amount: Double) {
//        unitsSoldShow()[index] += amount
    }
    
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
    
    func isActive(index: Int) -> Bool {
        return self.tableItemsVisible[index]
    }
    
    func monthsToShow() -> [String] {
        var result: [String] = []
        var index = 5
        while index < 65 {
            if self.isActive(index) {
                result.append(months[(index/5)-1])
            }
        index += 5
        }
        return result
    }
    
    func unitsSoldShow() -> [Double] {
        var result: [Double] = []
        var index = 5
        while index < 61 {
            // if the month is active, add its total from showing weeks
            if self.isActive(index) {
                result.append(getWeeksTotalForMonth(index))
            }
            // jump to next month in tableItems
            index += 5
        }
        return result
    }
    
    func getWeeksTotalForMonth(index: Int) -> Double {
        var result = 0.0
        for i in 1...4 {
            // if the week is active, add it to the total
            if self.isActive(index+i) {
                result += Double(self.tableItems[index+i])!
            }
        }
        return result
    }
}