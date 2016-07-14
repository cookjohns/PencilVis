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
    
    let months:        [String]! // reference
    let unitsSold:     [Double]! // reference
    var monthsToShow:  [String]! // chart data
    var unitsSoldShow: [Double]! // chart data
    var monthsVisible: [Bool]!   // currently showing
    var unitsVisible:  [Bool]!   // currently showing
    var weeksVisible:  [Bool]!   // currently showing
    var updated:        Bool!    // flag for update signal
    
    var spreadhSheetItems:       [String]!
    var spreadSheetVisibleItems: [Bool]!
    
    // MARK: - INITIALIZER
    
    init() {
        months        = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        unitsSold     = [34.0, 54.0, 74.0, 94.0, 114.0, 134.0, 154.0, 174.0, 93.0, 67.0, 54.0, 104.0]
        monthsToShow  = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        unitsSoldShow = [34.0, 54.0, 74.0, 94.0, 114.0, 134.0, 154.0, 174.0, 93.0, 67.0, 54.0, 104.0]
        monthsVisible = [true, true, true, true, true, true, true, true, true, true, true, true]
        unitsVisible  = [true, true, true, true, true, true, true, true, true, true, true, true]
        weeksVisible  = []
        for _ in 0..<65 {
            weeksVisible.append(true)
        }
        
        updated = false
        
        spreadhSheetItems = ["", "1", "2", "3", "4", "Jan", "7", "8", "9", "10", "Feb", "12", "13", "14", "15", "Mar", "17", "18", "19", "20", "Apr", "22", "23", "24", "25", "May", "27", "28", "29", "30", "Jun", "32", "33", "34", "35", "Jul", "37", "38", "39", "40", "Aug", "42", "43", "44", "45", "Sep", "28", "12", "11", "42", "Oct", "1", "19", "30", "17", "Nov", "6", "4", "15", "29", "Dec", "0", "37", "22", "45"]
        spreadSheetVisibleItems = []
        for _ in 0..<65 {
            spreadSheetVisibleItems.append(true)
        }
    }
    
    // MARK: - FUNCTIONS
    
    func deleteItem(index: Int) {
        
        var tempMonths: [String] = []
        var tempUnits:  [Double] = []
        
        // mark items as not visible
        monthsVisible[index] = false
        unitsVisible[index]  = false
        
        // recreate arrays with all visible items
        for i in 0...11 {
            if monthsVisible[i] {
                tempMonths.append(months[i])
                tempUnits.append(unitsSoldShow[i])
            }
        }
        monthsToShow  = tempMonths
        unitsSoldShow = tempUnits
    }
    
    func deactivate(index: Int) {
        self.spreadSheetVisibleItems[index] = false
        // if index is a month
        if (index > 4 && index % 5 == 0) {
            for i in 1...4 {
                self.spreadSheetVisibleItems[index+i] = false
            }
        }
    }
    
    func addItem(index: Int) {
        // mark item as visible, recreate arrays with all visible items
        
        unitsSoldShow.insert(unitsSold[index], atIndex: index)
        
        var tempMonths: [String] = []
        var tempUnits:  [Double] = []
        
        // mark items as visible
        monthsVisible[index] = true
        unitsVisible[index]  = true
        
        // recreate arrays with all visible items
        for i in 0...11 {
            if monthsVisible[i] {
                tempMonths.append(months[i])
                tempUnits.append(unitsSoldShow[i])
            }
        }
        monthsToShow  = tempMonths
        unitsSoldShow = tempUnits
    }
    
    func activate(index: Int) {
        self.spreadSheetVisibleItems[index] = true
        // if index is a month
        if (index > 4 && index % 5 == 0) {
            for i in 1...4 {
                self.spreadSheetVisibleItems[index+i] = true
            }
        }
    }
    
    func updateItem(index: Int, amount: Double) {
        unitsSoldShow[index] += amount
    }
    
    func totalUnitsShowing() -> Double {
        var result = 0.0
        for i in 0...unitsSoldShow.endIndex-1 {
            result += unitsSoldShow[i]
            print("\(unitsSoldShow[i]) (\(result))")
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
        return self.spreadSheetVisibleItems[index]
    }
}