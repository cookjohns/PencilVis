//
//  ViewController.swift
//  CollectionViewExample
//
//  Created by John Cook on 8/2/16.
//  Copyright © 2016 John Cook. All rights reserved.
//
//  Touch handling in this class recognizes circle
// 'Cross out' gesture recognized using intersections calculated in CanvasView.swift
//

import UIKit

class CollectionViewCanvas: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    // TODO: - UNDO???
    
    // MARK: - Properties
    // MARK: Chart
    
    var table:      Table!
    var detailView: DetailViewController!
    var textView:     UITextView!
    var clearButton:  UIButton!
    var workingData: [Double]! = []
    var cellLoadCount: Int = 0
    private let ReuseIdentifier = "cell" // also set as cell identifier in storyboard
    
    var canvas = CanvasView()
    var visualizeAzimuth = false
    
    // MARK: Circle
    
    private var touchedPoints = [CGPoint]() // point history
    var fitResult = CircleResult()  // info about how circle-like the path is
    var tolerance: CGFloat = 1.0     // "perfect circle" tolerance
    var isCircle = false
    var path = CGPathCreateMutable()
    enum circleState {
        case began
        case ended
        case cancelled
        case changed
        case failed
        case possible
    }
    var cState : circleState = .ended
    
    var storedCircledVal  = -1
    var currentCircledVal = -1
    var activeCircle  = false
    var selectedEmpty = false
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // containing view's background is white
        self.view.backgroundColor = UIColor.whiteColor()
        
        // the container's background should show through the collection view
        self.collectionView?.backgroundColor = UIColor.clearColor()
        
        // configure the collection view to look nice
        if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSizeMake(100, 100)
            layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15)
        }
        
        // make the canvas' background clear (to draw on top of collection view.)
        self.canvas.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.canvas)
        
        // add segmented controller for switching between chart types
        let segmentedControl = UISegmentedControl(items: ["Pie", "Line", "Bar"])
        segmentedControl.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        segmentedControl.addTarget(self, action: #selector(self.chartTypeChanged(_:)), forControlEvents: .ValueChanged)
        
        // add constraints for segmented controller
        let bottomContstraint  = segmentedControl.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: -8)
        let margins            = view.layoutMarginsGuide
        let leadingConstraint  = segmentedControl.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor)
        let trailingConstraint = segmentedControl.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor)
        
        bottomContstraint.active  = true
        leadingConstraint.active  = true
        trailingConstraint.active = true
        
        // setup textField
        textView = UITextView(frame: CGRectMake(100, 855.0, 300.0, 50.0))
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
        clearButton.frame = CGRect(x: 100.0, y: 925.0, width: 300, height: 40)
        clearButton.layer.cornerRadius = 8
        clearButton.backgroundColor    = UIColor(white: 0.9, alpha: 1)
        clearButton.layer.borderColor  = UIColor.grayColor().CGColor
        clearButton.layer.borderWidth  = 1
        clearButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        clearButton.setTitle("Clear annotation", forState: .Normal)
        clearButton.addTarget(self, action: #selector(clearAnnotation), forControlEvents: .TouchUpInside)
        self.view.addSubview(clearButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Whenever the container view lays out its subviews, make sure to stretch
        // the canvas over its entire bounds.
        self.canvas.frame = self.view.bounds
        
        // Also, make sure the canvas view is in front of the collection view and on-screen controls
        //        self.view.bringSubviewToFront(self.canvas)
    }
    
    // MARK: - Functions
    // MARK: - Gestures
    
    func didCrossOutCell(indexPath: NSIndexPath) {
        let index = indexPath.item
        let isMonth = index % 5 == 0 && index != 65 ? true : false
        let selectedAmount = Double(table.tableItems[indexPath.item])
        
        // check for valid selection box
        if (index < 5) {
            return
        }
        
        // if the selected cell is a month
        if (isMonth) {
            table.zeroOutMonth(index)
        }
            // otherwise, selected cell is a week
        else {
            // if non-zero, zero out
            if (selectedAmount != nil && selectedAmount != 0) {
                table.zeroOutWeek(index)
            }
        }
        
        // signal detailView to redraw chart
        detailView.updated = true
        collectionView?.reloadData()
    }
    
    // for testing - not currently used
    func didLongPress(sender: UILongPressGestureRecognizer) {
        // continuous gesture, so make sure that we only recognize it once
        if (sender.state == .Began) {
            // get location/indexPath/cell of touch, add it to textView, then add to workingData array
            let point = sender.locationInView(self.collectionView)
            let indexPath = self.collectionView!.indexPathForItemAtPoint(point)
            if indexPath != nil {
                let cell = self.collectionView!.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
                let units = Double(cell.label.text!)
                if let val = units {
                    textView.insertText("\(val)\n")
                    let range = NSMakeRange(textView.text.characters.count - 1, 0)
                    textView.scrollRangeToVisible(range)
                }
                workingData.append(units!)
            }
        }
    }
    
    // MARK: Interface
    
    func unitsForMonth(month: String) -> Double {
        // NOT WORKING
        let index = table.monthsIndexWithMatchingName(month)
        return table.unitsSold[index]
    }
    
    // fires when mathematical operator is entered into textView
    func textViewDidChange(textView: UITextView) {
        let lastChar = textView.text.characters.last
        
        // addition
        if (lastChar == "+") {
            let result = currentCircledVal + storedCircledVal
            textView.insertText("\nTotal: \(result)\n\n")
            let range = NSMakeRange(textView.text.characters.count - 1, 0)
            textView.scrollRangeToVisible(range)
            storedCircledVal  = -1
            currentCircledVal = -1
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
            let range = NSMakeRange(textView.text.characters.count - 1, 0)
            textView.scrollRangeToVisible(range)
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
            let range = NSMakeRange(textView.text.characters.count - 1, 0)
            textView.scrollRangeToVisible(range)
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
            let range = NSMakeRange(textView.text.characters.count - 1, 0)
            textView.scrollRangeToVisible(range)
            workingData = []
        }
    }
    
    @IBAction func clearAnnotation(sender: UIButton) {
        print("Button pressed")
        
        // pop up alert
        let title = "Delete annotations?"
        let message = "Are you sure you want to delete all annotations from the spreadsheet and \(currentChartName()) chart?"
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        // alert actions
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            (action) -> Void in
            
            // do the annotations deletion
            self.detailView.canvasView.clear()
            self.canvas.clear()
            
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
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.table.COUNT
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let isMonth = index % 5 == 0 && index < 65 ? true : false
        
        // get a reference to the storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        // set up cell's appearance
        cell.layer.borderColor  = UIColor.grayColor().CGColor
        cell.layer.borderWidth  = 0.5
        cell.label.text = self.table.tableItems[index]
        cell.label.textAlignment = .Center
        let textAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20.0)!]
        let text = NSAttributedString(string: "\(table.tableItems[indexPath.item])", attributes: textAttributes)
        cell.label.attributedText = text
        

        // catch for top line
        if index < 5 {
            cell.contentView.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1)
        }
        // if cell is month label, set blue background
        else if (isMonth) {
            cell.contentView.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1)
        }
        //  if cell is week, set white background and black text (or top left cell)
        else {
            cell.contentView.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    // use for tapping on cell to add data
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // anchor alert pop-up with text entry to indexpath
        
        // populate cell with text entry (check for digits only)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    // side-to-side
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return -0.5
    }
    
    // top-to-bottom
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // cell size based on percentage of frame width
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 5.41
        return CGSize(width: cellWidth, height: 50)
    }
    
    // insets, leveraged to eliminate vertical spaces
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: -24.0, left: 19.5, bottom: 10.0, right: 19.5)
        return sectionInsets
    }
    
    // MARK: - Circle Gesture
    
    func findAndUseCircledCell(center: CGPoint) {
        // walk through the image views and see if the center of the drawn circle was over one of the views
        print(self.collectionView!.indexPathForItemAtPoint(center)?.row)
        let indexPath = self.collectionView!.indexPathForItemAtPoint(center)
        if indexPath != nil {
            let indexPathInt = self.collectionView!.indexPathForItemAtPoint(center)?.row
            let cell = self.collectionView!.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
            let label = cell.label.text
            
            // set values for circled item
            if (label == "") {
                selectedEmpty = true
            }
            
            // is it a month? if not, set up prev/current values
            let labelInt = Int(label!)
            if (labelInt == nil) {
                // circled a month
            }
            else {
                textView.insertText("\(String(labelInt!))\n")
                let range = NSMakeRange(textView.text.characters.count - 1, 0)
                textView.scrollRangeToVisible(range)
                if (storedCircledVal == -1) {
                    storedCircledVal  = Int(label!)!
                    currentCircledVal = Int(label!)!
                }
                else {
                    currentCircledVal = Int(label!)!
                }
            }
            
            // what if we've previously selected a circle during this gesture?
            if (activeCircle) {
                // previous circle active, do something with that stored data
                if (selectedEmpty && storedCircledVal >= 0) {
                    table.tableItems[indexPathInt!] = String(storedCircledVal)
                    self.collectionView!.reloadData()
                    
                    // reset storage, activity, etc.
                    activeCircle  = false
                    selectedEmpty = false
                    storedCircledVal  = -1
                    currentCircledVal = -1
                }
                else {
                    // not an empty cell, so we're doing an operation on the previously selected cell
                    
                }
            }
            else {
                // dont set 'active' if first cell selected is empty... instead, do nothing
                if (!selectedEmpty) {
                    activeCircle = true
                }
                else {
                    // reset values because empty cell was selected first
                    activeCircle  = false // we don't really need to do this here, just remember that activeCircle should remain false
                    selectedEmpty = false
                    storedCircledVal  = -1
                    currentCircledVal = -1
                }
            }
            
            print("Circled cell is \(cell.label.text!)")
        }
    }
    
    private func anyPointsInTheMiddle() -> Bool {
        let fitInnerRadius = fitResult.radius / sqrt(2) * tolerance
        
        let innerBox = CGRect(
            x: fitResult.center.x - fitInnerRadius,
            y: fitResult.center.y - fitInnerRadius,
            width: 2 * fitInnerRadius,
            height: 2 * fitInnerRadius)
        
        var hasInside = false
        for point in touchedPoints {
            if innerBox.contains(point) {
                hasInside = true
                break
            }
        }
        return hasInside
    }
    
    private func calculateBoundingOverlap() -> CGFloat {
        let fitBoundingBox = CGRect(
            x: fitResult.center.x - fitResult.radius,
            y: fitResult.center.y - fitResult.radius,
            width:  2 * fitResult.radius,
            height: 2 * fitResult.radius)
        let pathBoundingBox = CGPathGetBoundingBox(path) //path.boundingBox
        
        let overlapRect = fitBoundingBox.intersect(pathBoundingBox)
        
        let overlapRectArea = overlapRect.width * overlapRect.height
        let circleBoxArea = fitBoundingBox.width * fitBoundingBox.height
        
        let percentOverlap = overlapRectArea / circleBoxArea
        return percentOverlap
    }
    
    func reset() {
        touchedPoints.removeAll(keepCapacity: true)
        path = CGPathCreateMutable()
        isCircle = false
        cState = .possible
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first!.type == .Stylus {
            canvas.drawTouches(touches, withEvent: event)
        }
        else {
            let indexPath = collectionView?.indexPathForItemAtPoint((touches.first?.locationInView(self.view))!)
            if indexPath != nil {
                self.collectionView(collectionView!, didSelectItemAtIndexPath: indexPath!)
            }
        }
        
        // circle stuff
        if (touches.count != 1) {
            cState = .failed // cancel the gesture if more than one finger is involved
        }
        cState = .began
        
        let window = view?.window
        if let touches = touches as? Set<UITouch>, loc = touches.first?.locationInView(window) {
            CGPathMoveToPoint(path, nil, loc.x, loc.y)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.collectionView?.touchesBegan(touches, withEvent: event)
        canvas.drawTouches(touches, withEvent: event)
        
        // circle stuff
        
        // don't process other touches if gesture has already failed
        if cState == .failed {
            return
        }
        
        let window = view?.window
        if let touches = touches as? Set<UITouch>, loc = touches.first?.locationInView(window) {
            touchedPoints.append(loc)
            CGPathMoveToPoint(path, nil, loc.x, loc.y)
            cState = .changed
        }
    }
    
    // MARK: ** Handles gestures **
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvas.drawTouches(touches, withEvent: event)
        canvas.endTouches(touches, cancel: false)
        if (touches.first!.type == .Stylus) {
            let intersection = canvas.getIntersection()
            if intersection.x >= 0 {
                print("Intersection x at \(intersection.x)")
                let indexPath = collectionView?.indexPathForItemAtPoint(intersection)
                if indexPath != nil {
                    didCrossOutCell(indexPath!)
                }
                return
            }
            else {
                // circle stuff
                
                // determine if path was circle
                fitResult = fitCircle(touchedPoints)
                
                // check for points in the middle of the circle
                let hasInside = anyPointsInTheMiddle()
                
//                let boundingOverlap = calculateBoundingOverlap()
                isCircle = fitResult.error <= tolerance && hasInside //&& calculateBoundingOverlap() > (1-tolerance)
                cState = isCircle ? .ended : .failed // fail or end, based on isCircle
                if (isCircle && cState == .ended) {
                    findAndUseCircledCell(fitResult.center)
                }
            }
        }
        reset()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touches = touches else { return }
        canvas.endTouches(touches, cancel: true)
        cState = .cancelled
    }
    
    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
        canvas.updateEstimatedPropertiesForTouches(touches)
    }
}