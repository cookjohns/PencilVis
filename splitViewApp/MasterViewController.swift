//
//  MasterViewController.swift
//  splitViewApp
//
//  Created by John Cook on 6/11/16.
//  Copyright © 2016 John Cook. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    // MARK: - VARIABLES
    
//    @IBOutlet weak var canvasView: CanvasView!
//    var visualizeAzimuth = false
    
    var table:      Table!
    var detailView: DetailViewController!
    let reuseIdentifier = "cell" // also set as cell identifier in storyboard
    var textView:     UITextView!
    var clearButton:  UIButton!
    var workingData: [Double]! = []
    
    var circleRecognizer: CircleGestureRecognizer!
    
    var canvasView = CanvasView()
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - FUNCTIONS
    
    override func loadView() {
        super.loadView()
        
        // add segmented controller for switching between chart types
        let segmentedControl = UISegmentedControl(items: ["Pie", "Line", "Bar"])
        segmentedControl.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        segmentedControl.addTarget(self, action: #selector(MasterViewController.chartTypeChanged(_:)), forControlEvents: .ValueChanged)
        
        // add constraints for segmented controller
        let bottomContstraint  = segmentedControl.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: -8)
        let margins            = view.layoutMarginsGuide
        let leadingConstraint  = segmentedControl.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor)
        let trailingConstraint = segmentedControl.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor)
        
        bottomContstraint.active  = true
        leadingConstraint.active  = true
        trailingConstraint.active = true
        
        // setup textField
        textView = UITextView(frame: CGRectMake(100, 730.0, 300.0, 150.0))
        textView.textAlignment      = NSTextAlignment.Left
        textView.textColor          = UIColor.blueColor()
        textView.backgroundColor    = UIColor(white: 0.9, alpha: 1)
        textView.layer.borderColor  = UIColor.grayColor().CGColor
        textView.layer.borderWidth  = 2
        textView.layer.cornerRadius = 8
        self.view.addSubview(textView)
        textView.delegate = self
        
        // setup clear button
        clearButton = UIButton()
        clearButton.frame = CGRect(x: 100.0, y: 900.0, width: 300, height: 40)
        clearButton.layer.cornerRadius = 8
        clearButton.backgroundColor    = UIColor(white: 0.9, alpha: 1)
        clearButton.layer.borderColor  = UIColor.grayColor().CGColor
        clearButton.layer.borderWidth  = 1
        clearButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        clearButton.setTitle("Clear annotation", forState: .Normal)
        clearButton.addTarget(self, action: #selector(clearAnnotation), forControlEvents: .TouchUpInside)
        self.view.addSubview(clearButton)
        
        // add long press gesture recognizer to simulate circling with pencil
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        self.view.addGestureRecognizer(longPress)
        
        //circleRecognizer = CircleGestureRecognizer(target: self, action: #selector(circled))
        //view.addGestureRecognizer(circleRecognizer)
        
        self.view.addSubview(canvasView)
        canvasView.hidden = false
    }
    
    /* Use segmented controller to signal detailView to change chart subview */
    func chartTypeChanged(segControl: UISegmentedControl) {
        switch segControl.selectedSegmentIndex {
        case 0:
            // pie chart
            detailView.changeChartType(0)
            break
        case 1:
            // line graph
            detailView.changeChartType(1)
            break
        case 2:
            // bar graph
            detailView.changeChartType(2)
            break
        default:
            break
        }
    }
    
    func didLongPress(sender: UILongPressGestureRecognizer) {
        // continuous gesture, so make sure that we only recognize it once
        if (sender.state == .Began) {
            // get location/indexPath/cell of touch, add it to textView, then add to workingData array
            let point = sender.locationInView(self.collectionView)
            let indexPath = self.collectionView.indexPathForItemAtPoint(point)
            if let index = indexPath {
                let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
                let units = Double(cell.label.text!)
                if let val = units {
                    textView.insertText("\(val)\n")
                }
                workingData.append(units!)
            }
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let lastChar = textView.text.characters.last
        
        // addition
        if (lastChar == "+") {
            // show addition of everything in workingData, then clear it out
            var result = workingData[0]
            for i in 1..<workingData.count {
                result = result + workingData[i]
            }
            textView.insertText("\nTotal: \(result)")
            workingData = []
        }
        
        // subtraction
        if (lastChar == "-") {
            // show addition of everything in workingData, then clear it out
            var result = workingData[0]
            for i in 1..<workingData.count {
                result = result - workingData[i]
            }
            textView.insertText("\nTotal: \(result)")
            workingData = []
        }
        
        // multiplication
        if (lastChar == "*") {
            // show addition of everything in workingData, then clear it out
            var result = workingData[0]
            for i in 1..<workingData.count {
                result = result * workingData[i]
            }
            textView.insertText("\nTotal: \(result)")
            workingData = []
        }
        
        // division
        if (lastChar == "/") {
            // show addition of everything in workingData, then clear it out
            var result = workingData[0]
            for i in 1..<workingData.count {
                result = result / workingData[i]
            }
            textView.insertText("\nTotal: \(result)")
            workingData = []
        }
    }
    
    @IBAction func clearAnnotation(sender: UIButton) {
        print("Button pressed")
        
        // pop up alert
        let title = "Delete annotations?"
        let message = "Are you sure you want to delete all annotations from the \(currentChartName()) chart?"
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        // alert actions
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            (action) -> Void in
            
            // do the annotations deletion
            self.detailView.canvasView.clear()
            
            // clear the textView
            self.textView.text = ""
        })
        ac.addAction(deleteAction)
        
        // provide location for popover (iPad specific)
        let popover = ac.popoverPresentationController
        popover?.sourceView = self.view
        popover?.sourceRect = CGRectMake(100, 900, 300, 40)
        popover?.permittedArrowDirections = UIPopoverArrowDirection.Any
        
        // present the alert controller
        presentViewController(ac, animated: true, completion: nil)
    }
    
    private func currentChartName() -> String {
        if (self.detailView.pieChartView.hidden == false) {
            return "pie"
        }
        else if (self.detailView.lineChartView.hidden == false) {
            return "line"
        }
        else if (self.detailView.barChartView.hidden == false) {
            return "bar"
        }
        else {
            return "current"
        }
    }
    
    //    func findCircledCell(center: CGPoint) {
    //        // walk through the image views and see if the center of the drawn circle was over one of the views
    //        let indexPath = self.collectionView.indexPathForItemAtPoint(center)
    //        if let index = indexPath {
    //            let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
    //            let units = unitsForMonth(cell.label.text!)
    //            textView.insertText("\(units)\n")
    //            workingData.append(units)
    //            print("Circled cell is \(cell.label.text), \(units) units.")
    //        }
    //    }
    //
    //    func circled(c: CircleGestureRecognizer) {
    //        if (c.state == .Ended) {
    //            //print("Made a circle")
    //            findCircledCell(c.fitResult.center)
    //        }
    
    //        if (c.state == .Began) {
    //            circlerDrawer.clear()
    //        }
    //        if (c.state == .Changed) {
    //            circlerDrawer.updatePath(c.path)
    //        }
    //        if (c.state == .Ended || c.state == .Failed || c.state == .Cancelled) {
    //            circlerDrawer.updateFit(c.fitResult, madeCircle: c.isCircle)
    //        }
    //    }
    
    //    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //        canvasView.drawTouches(touches, withEvent: event)
    //
    //        if visualizeAzimuth {
    //            for touch in touches {
    //                if touch.type == .Stylus {
    //                    //reticleView.hidden = false
    //                    //updateReticleViewWithTouch(touch, event: event)
    //                }
    //            }
    //        }
    //    }
    //
    //    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //        canvasView.drawTouches(touches, withEvent: event)
    //
    //        if visualizeAzimuth {
    //            for touch in touches {
    //                if touch.type == .Stylus {
    //                    //updateReticleViewWithTouch(touch, event: event)
    //
    //                    // Use the last predicted touch to update the reticle.
    //                    //guard let predictedTouch = event?.predictedTouchesForTouch(touch)?.last else { return }
    //
    //                    //updateReticleViewWithTouch(predictedTouch, event: event, isPredicted: true)
    //                }
    //            }
    //        }
    //    }
    //
    //    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //        canvasView.drawTouches(touches, withEvent: event)
    //        canvasView.endTouches(touches, cancel: false)
    //
    //        if visualizeAzimuth {
    //            for touch in touches {
    //                if touch.type == .Stylus {
    //                    //reticleView.hidden = true
    //                }
    //            }
    //        }
    //    }
    //
    //    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    //        guard let touches = touches else { return }
    //        canvasView.endTouches(touches, cancel: true)
    //
    //        if visualizeAzimuth {
    //            for touch in touches {
    //                if touch.type == .Stylus {
    //                    //reticleView.hidden = true
    //                }
    //            }
    //        }
    //    }
    //    
    //    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
    //        canvasView.updateEstimatedPropertiesForTouches(touches)
    //    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.items.count
        return self.table.COUNT
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        
        // get a reference to the storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        // set up cell's appearance
        cell.layer.borderColor  = UIColor.grayColor().CGColor
        cell.layer.borderWidth  = 0.5
        cell.label.text = self.table.tableItems[indexPath.item]
        
        if (index < 6 || index % 5 == 0) {
            // set background to lightblue for title fields
            cell.contentView.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1)
            if index != 0 {
                let textAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 32.0)!]
                let text = NSAttributedString(string: "\(table.tableItems[indexPath.item])", attributes: textAttributes)
                cell.label.attributedText = text
            }
        }
        // if cell is active month label, set blue background
        if (index % 5 == 0 && table.isActive(index)) {
            cell.contentView.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1)
        }
        // if cell is inactive month label, set background to gray color
        else if (index % 5 == 0 && !table.isActive(index)) {
            cell.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
        // if cell is active, set white background and black text
        else if (table.isActive(index)) {
            cell.contentView.backgroundColor = UIColor.whiteColor()
            cell.label.textColor = UIColor.blackColor()
        }
        // cell is inactive, set white background and gray text
        else if (!table.isActive(index)) {
            cell.contentView.backgroundColor = UIColor.whiteColor()
            cell.label.textColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //print("You selected cell #\(indexPath.item)!")
        
        let index = indexPath.item
        
        // check for valid selection box
        if (index < 5) {
            return
        }
        
        // create array for storing index path's to be updated
        var indices = [indexPath]
        
        // get month index
        let selectedMonth  = (index / 5) - 1
        
        // if the selected cell is a month
        if (index > 4 && index % 5 == 0) {
            // active, so make inactive, then delete item in table and change cell color
            if table.isActive(index) {
                table.deactivate(index)
            }
            // inactive, so make it active, then add item back to table and change cell color
            else {
                table.activate(index)
            }
            // add index path's of weeks in selected month
            for i in 1...4 {
                var path = NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section)
                indices.append(path)
            }
        }
        // otherwise, selected cell is a week
        else {
            // if selected month is inactive, break
            let selectedMon = (index/5) * 5
            if !table.isActive(selectedMon) {
                return
            }
            
            let selectedAmount = Double(table.tableItems[indexPath.item])

            // active, so make it inactive, then delete the week amount from total and gray out text color
            if table.isActive(index) {
                table.deactivate(index)
                // change value for month in chart
                table.updateItem(selectedMonth, amount: -(selectedAmount!))
            }
            // inactive, so make it active, then add week amount back in and recolor cell text
            else {
                table.activate(index)
                // change value for month in chart
                table.updateItem(selectedMonth, amount: selectedAmount!)
            }
        }
        
        // signal detailView to redraw chart
        detailView.updated = true
        // signal collectionView to reload cell colors to reflect activity
        collectionView.reloadItemsAtIndexPaths(indices)
    }
    
    // MARK: - UICOllectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return -0.5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 5.0
        return CGSize(width: cellWidth, height: 50)
    }
    
    // MARK: - Touches for CanvasView
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvasView.drawTouches(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvasView.drawTouches(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvasView.drawTouches(touches, withEvent: event)
        canvasView.endTouches(touches, cancel: false)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touches = touches else { return }
        canvasView.endTouches(touches, cancel: true)
    }
    
    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
        canvasView.updateEstimatedPropertiesForTouches(touches)
    }
}