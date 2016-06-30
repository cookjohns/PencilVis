//
//  DetailViewController.swift
//  splitViewApp
//
//  Created by John Cook on 6/11/16.
//  Copyright © 2016 John Cook. All rights reserved.
//

import UIKit
import Charts

class DetailViewController: UIViewController {
    
    // MARK: - PROPERTIES
    
    @IBOutlet weak var pieCanvasView:  CanvasView!
    @IBOutlet weak var lineCanvasView: CanvasView!
    @IBOutlet weak var barCanvasView:  CanvasView!
    @IBOutlet weak var pieChartView:   PieChartView!
    @IBOutlet weak var barChartView:   BarChartView!
    @IBOutlet weak var lineChartView:  LineChartView!
    
    var canvasView: CanvasView!
    var visualizeAzimuth = false
    var table: Table!
    var masterView: MasterViewController!
    var pieChartColors: [String : UIColor]!
    var updated: Bool! {
        didSet {
            if updated == true {
                // reload chart with new values when value changes
                updateDataSets(table.monthsToShow, values: table.unitsSoldShow)
                pieChartView.notifyDataSetChanged()
                lineChartView.notifyDataSetChanged()
                barChartView.notifyDataSetChanged()
            }
        }
    }
    
    // MARK: - FUNCTIONS
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // instantiate the empty dictionary
        pieChartColors = [String : UIColor]()

        // set up chart
        setChart(table.monthsToShow, values: table.unitsSoldShow)
        
        // set up tap recognizer for double taps (need discrete gesture for each view)
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTapsRequired = 2
        pieChartView.addGestureRecognizer(tap)
        let tapBar = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tapBar.numberOfTapsRequired = 2
        barChartView.addGestureRecognizer(tapBar)
        let tapLine = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tapLine.numberOfTapsRequired = 2
        lineChartView.addGestureRecognizer(tapLine)
        
        // start by showing pieChartView
        pieChartView.hidden  = false
        lineChartView.hidden = true
        barChartView.hidden  = true
        
        pieCanvasView.hidden  = false
        lineCanvasView.hidden = false
        barCanvasView.hidden  = false
        
        // disable ios-charts pieChartView rotation
        pieChartView.rotationEnabled = false
        
        // initialize canvasView to pie chart
        canvasView = pieCanvasView
    }
    
    // MARK: - Chart
    
    func setChart(dataPoints:[String], values: [Double]) {
        pieChartView.noDataText = "You need to provide data for the chart"
        
        // add dataPoints to chart's dataPoints array
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        // set pie chart data
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
        let pieChartData    = PieChartData(xVals: table.monthsToShow, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        // set up pie chart center text
        let textAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 32.0)!]
        let centerText = NSAttributedString(string: "Total: \(table.totalUnitsShowing())", attributes: textAttributes)
        pieChartView.centerAttributedText = centerText
        
        // set up chart colors, and save references in dictionary
        var colors: [UIColor] = []
        
        
        for i in 0..<dataPoints.count {
            let red   = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue  = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
            
            // save in dictionary
            pieChartColors[dataPoints[i]] = color
        }
        
        pieChartDataSet.colors = colors
        
        // set up bar chart data
        let barChartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        let barChartData    = BarChartData(xVals: table.monthsToShow, dataSet: barChartDataSet)
        barChartView.data = barChartData
        
        // set up line chart data
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        let lineChartData    = LineChartData(xVals: table.monthsToShow, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        // remove "Description" label from charts
        pieChartView.descriptionText  = ""
        lineChartView.descriptionText = ""
        barChartView.descriptionText  = ""
        
        // disable drag on line and bar charts because drag (pan) gesture recognizer 
        // interferes with CanvasView's ability to draw
        lineChartView.dragEnabled = false
        barChartView.dragEnabled  = false
    }
    
    func changeChartType(index: Int) {
        switch index {
        case 0:
            // pie chart visible
            pieChartView.hidden  = false
            barChartView.hidden  = true
            lineChartView.hidden = true
            canvasView = pieCanvasView
        case 1:
            // line graph visible
            lineChartView.hidden = false
            pieChartView.hidden  = true
            barChartView.hidden  = true
            canvasView = lineCanvasView
        case 2:
            // bar graph visible
            barChartView.hidden  = false
            pieChartView.hidden  = true
            lineChartView.hidden = true
            canvasView = barCanvasView
        default:
            break
        }
    }
    
    func updateDataSets(dataPoints:[String], values: [Double]) {
        // add dataPoints to chart's dataPoints array
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        // set pie chart data
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
        pieChartDataSet.colors = updatedPieChartColors()
        let pieChartData    = PieChartData(xVals: table.monthsToShow, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        // set up bar chart data
        let barChartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        let barChartData    = BarChartData(xVals: table.monthsToShow, dataSet: barChartDataSet)
        barChartView.data = barChartData
        
        // set up line chart data
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        let lineChartData    = LineChartData(xVals: table.monthsToShow, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        // update pie chart center text (total)
        let textAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 32.0)!]
        let centerText = NSAttributedString(string: "Total: \(table.totalUnitsShowing())", attributes: textAttributes)
        pieChartView.centerAttributedText = centerText
    }
    
    func updatedPieChartColors() -> [UIColor] {
        var colors: [UIColor] = []
        for i in table.monthsToShow {
            colors.append(pieChartColors[i]!)
        }
        return colors
    }
    
    // MARK: - Touch Handling
    
    // FIXME: - double tap outside of chart causes crash
    func doubleTap() {
        //print("Double tap recognized at cell \(pieChartView.highlighted[0].xIndex)")
        
        let highlightedPointName = table.monthsToShow[pieChartView.highlighted[0].xIndex]
        let pointToDelete = table.monthsIndexWithMatchingName(highlightedPointName)
        
        // delete item from table, reload current view's chart
        if (pieChartView.hidden == false) {
            table.deleteItem(pointToDelete)
            //print("Double tap recognized")
        }
        else if (lineChartView.hidden == false) {
            table.deleteItem(pointToDelete)
        }
        else {
            table.deleteItem(pointToDelete)
        }
        // update charts with new data set
        updateDataSets(table.monthsToShow, values: table.unitsSoldShow)
        pieChartView.notifyDataSetChanged()
        lineChartView.notifyDataSetChanged()
        barChartView.notifyDataSetChanged()
        
        // trigger the masterView's UICollectionView to reload it's data/cells (to change appearance for in/active)
        masterView.collectionView.reloadData()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvasView.drawTouches(touches, withEvent: event)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .Stylus {
                    //reticleView.hidden = false
                    //updateReticleViewWithTouch(touch, event: event)
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvasView.drawTouches(touches, withEvent: event)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .Stylus {
                    //updateReticleViewWithTouch(touch, event: event)
                    
                    // Use the last predicted touch to update the reticle.
                    //guard let predictedTouch = event?.predictedTouchesForTouch(touch)?.last else { return }
                    
                    //updateReticleViewWithTouch(predictedTouch, event: event, isPredicted: true)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvasView.drawTouches(touches, withEvent: event)
        canvasView.endTouches(touches, cancel: false)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .Stylus {
                    //reticleView.hidden = true
                }
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touches = touches else { return }
        canvasView.endTouches(touches, cancel: true)
        
        if visualizeAzimuth {
            for touch in touches {
                if touch.type == .Stylus {
                    //reticleView.hidden = true
                }
            }
        }
    }
    
    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
        canvasView.updateEstimatedPropertiesForTouches(touches)
    }
    
    // MARK: Rotation
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.LandscapeLeft, .LandscapeRight]
    }
}