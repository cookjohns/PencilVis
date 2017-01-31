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
    
    // MARK: - VARIABLES
    
    private var tableItems: [String]! // all items in "spreadsheet" table
    private var size: Int             // total number of items in table
    
    // MARK: - INITIALIZER
    
    init() {
        tableItems = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "13", "14", "15", "21", "17", "18", "19", "20", "53", "22", "23", "24", "25", "68", "27", "28", "29", "30", "201", "32", "33", "34", "35", "19", "37", "38", "39", "40", "0", "42", "43", "44", "45", "1", "28", "12", "11", "42", "12", "1", "19", "30", "17", "13", "6", "4", "15", "29", "28", "0", "37", "22", "45", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
        
        size    = tableItems.count
    }
    
    // MARK: - FUNCTIONS
    
    func updateTable(index: Int, input: String) {
        tableItems[index] = input
        if index < 192 {
//            size += 1
        }
    }
    
    func removeFromTable(index: Int) {
        tableItems[index] = ""
        size -= 1
    }
    
    func getTableItem(index: Int) -> String {
        if index >= size {
            return ""
        }
        return tableItems[index]
    }
    
    func getSize() -> Int {
        return size
    }
}