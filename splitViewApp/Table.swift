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
    var updated:        Bool!    // flag for update signal
    
    // MARK: - INITIALIZER
    
    init() {
        months        = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        unitsSold     = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        monthsToShow  = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        unitsSoldShow = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        monthsVisible = [true, true, true, true, true, true, true, true, true, true, true, true]
        unitsVisible  = [true, true, true, true, true, true, true, true, true, true, true, true]
        updated       = false
    }
    
    // MARK: - FUNCTIONS
    
    // FIXME: - deleting random items can still cause crash
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
                tempUnits.append(unitsSold[i])
            }
        }
        monthsToShow  = tempMonths
        unitsSoldShow = tempUnits
    }
    
    func addItem(index: Int) {
        // mark item as visible, recreate arrays with all visible items
        
        var tempMonths: [String] = []
        var tempUnits:  [Double] = []
        
        // mark items as visible
        monthsVisible[index] = true
        unitsVisible[index]  = true
        
        // recreate arrays with all visible items
        for i in 0...11 {
            if monthsVisible[i] {
                tempMonths.append(months[i])
                tempUnits.append(unitsSold[i])
            }
        }
        monthsToShow  = tempMonths
        unitsSoldShow = tempUnits
    }
    
    func totalUnitsShowing() -> Double {
        var result = 0.0
        for i in unitsSoldShow {
            result = result + i
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
}