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

class CollectionViewCanvas: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // TODO: - UNDO???
    
    // MARK: - Properties
    // MARK: Chart
    
    var table:      Table!
    var detailView: DetailViewController!
    var clearButton:  UIButton!
    var workingData: [Double]! = []
    var selectedValues: [Double] = []
    var highlighted: [Bool] = []
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
//    var selectedEmpty = false
    
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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        self.view.addGestureRecognizer(longPress)
        
        for _ in 0..<table.tableItems.count {
            highlighted.append(false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Whenever the container view lays out its subviews, make sure to stretch
        // the canvas over its entire bounds.
        self.canvas.frame = self.view.bounds
    }
    
    // MARK: - Functions
    // MARK: - Gestures
    
    func didCrossOutCell(indexPath: NSIndexPath) {
        let index = indexPath.item
        var indices = [indexPath]
        
        // check for valid selection box
        if (index < 12) {
            return
        }
        
        table.tableItems[index] = ""
        
        let path = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
        indices.append(path)
        self.collectionView!.reloadItemsAtIndexPaths(indices)
//        self.collectionView?.reloadData()
    }
    
    // for testing - not currently used
    func didLongPress(sender: UILongPressGestureRecognizer) {
        // continuous gesture, so make sure that we only recognize it once
        if (sender.state == .Began) {
            // get location/indexPath/cell of touch, add it to textView, then add to workingData array
            let point = sender.locationInView(self.collectionView)
            let indexPath = self.collectionView!.indexPathForItemAtPoint(point)
            let index = indexPath!.item
            var indices = [indexPath!]
            if indexPath != nil {
                let cell = self.collectionView!.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
                
                // set values for circled item
                if (cell.label.text == "") {
//                    table.tableItems[index] = "\(selectedValues[0]!)"
//                    self.collectionView?.reloadData()
                    return
                }
                
                // is it a month? if not, set up prev/current values
                if (index < 12) {
                    return
                }
                else {
                    let val = Double(cell.label.text!)
                    selectedValues.append(val!)
                    highlighted[index] = true
                    
                    let path = NSIndexPath(forRow: indexPath!.row, inSection: indexPath!.section)
                    indices.removeAll()
                    indices.append(path)
                    self.collectionView!.reloadItemsAtIndexPaths(indices)
//                        self.collectionView!.reloadData()
                }
                print("Circled cell is \(cell.label.text!)")
            }
        }
    }
    
    func resultOfOperator(op: String, selectedValues: [Double], newVal: Double) -> Double {
        let c = op.characters.last
        if (c == "+") {
            return selectedValues[selectedValues.count] + newVal
        }
        if (c == "-") {
            return selectedValues[selectedValues.count] - newVal
        }
        if (c == "*") {
            return selectedValues[selectedValues.count] * newVal
        }
        if (c == "/") {
            return selectedValues[selectedValues.count] / newVal
        }
        if (c == "%") {
            return selectedValues[selectedValues.count] % newVal
        }
        return -1
    }
    
    // MARK: Interface
    
    func unitsForMonth(month: String) -> Double {
        // NOT WORKING
        let index = table.monthsIndexWithMatchingName(month)
        return table.unitsSold[index]
    }
    
    @IBAction func clearAnnotation(sender: UIButton) {
        print("Button pressed")
        
        // pop up alert
        let title = "Delete annotations?"
        let message = "Are you sure you want to delete all annotations?"
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        // alert actions
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            (action) -> Void in
            
            // do the annotations deletion
            self.canvas.clear()
            
            // reset the selected value array
            self.selectedValues = []
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
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.table.COUNT
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        
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
        
        // set highlighted background if necessary
        if highlighted[index] == true {
            cell.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.9)
//            cell.backgroundColor = UIColor.blueColor()
        }
        
        // set up operator cells
        if selectedValues.count == 2 {
            // + operator
            if index == 192 {
                cell.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
                cell.label.text = "+"
            }
            //- operator
            if index == 193 {
                cell.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
                cell.label.text = "-"
            }
            // +* operator
            if index == 194 {
                cell.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
                cell.label.text = "*"
            }
            // / operator
            if index == 195 {
                cell.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
                cell.label.text = "/"
            }
        }
        if selectedValues.count > 2 {
            // sum operator
            if index == 192 {
                cell.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
                cell.label.text = "SUM"
            }
        }
        
        return cell
    }
    
    func setupOperatorCells() {
        let path1 = NSIndexPath(forRow: 192, inSection: 0)
        let path2 = NSIndexPath(forRow: 193, inSection: 0)
        let path3 = NSIndexPath(forRow: 194, inSection: 0)
        let path4 = NSIndexPath(forRow: 195, inSection: 0)
        var indices = [path1, path2, path3, path4]
        collectionView!.reloadItemsAtIndexPaths(indices)
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    // use for tapping on cell to add data
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.item
        //        let isMonth = index % 5 == 0 && index != 65 ? true : false
        var indices = [indexPath]
        
        // check for valid selection box
        if (index < 12) {
            return
        }
        
        let alert = UIAlertController(title:   "Insert value",
                                      message: "",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default,
                                       handler: { (action:UIAlertAction) -> Void in
                                        
                                        let textField = alert.textFields!.first
                                        self.table.tableItems[index] = (textField?.text)!
                                        
                                        let path = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
                                        indices.append(path)
                                        self.collectionView!.reloadItemsAtIndexPaths(indices)
//                                        self.collectionView?.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
                              animated:   true,
                              completion: nil)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    // side-to-side
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return -1
    }
    
    // top-to-bottom
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // cell size based on percentage of frame width
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 12.41
        return CGSize(width: cellWidth, height: 50)
    }
    
    // insets, leveraged to eliminate vertical spaces
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: -24.0, left: 22.5, bottom: 10.0, right: 22.5)
        return sectionInsets
    }

    
    // MARK: - Circle Gesture
    
    func useCircledCell(center: CGPoint) {
        // walk through the image views and see if the center of the drawn circle was over one of the views
//        print(self.collectionView!.indexPathForItemAtPoint(center)?.row)
//        let indexPath = self.collectionView!.indexPathForItemAtPoint(center)
//        var indices = [indexPath!]
//        let index = indexPath!.item
//        if indexPath != nil {
//            let index = self.collectionView!.indexPathForItemAtPoint(center)?.row
//            let cell = self.collectionView!.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
//            
//            // set values for circled item
//            if (cell.label.text == "") {
//                table.tableItems[index!] = "\(selectedValues[0])"
////                self.collectionView?.reloadData()
//                return
//            }
//            
//            // is it a month? if not, set up prev/current values
//            if (index < 12) {
//                return
//            }
//            else {
//                let val = Double(cell.label.text!)
//                selectedValues.append(val!)
//                highlighted[index!] = true
//                
//                let path = NSIndexPath(forRow: indexPath!.row, inSection: indexPath!.section)
//                indices.removeAll()
//                indices.append(path)
//                self.collectionView!.reloadItemsAtIndexPaths(indices)
//            }
//            print("Circled cell is \(cell.label.text!)")
//        }
    }
    
    func useSelectedCell(indexIn: NSIndexPath) {
        let index = indexIn.item
        var indices = [indexIn]
        let cell = self.collectionView!.cellForItemAtIndexPath(indexIn) as! CollectionViewCell
        let val = Double(cell.label.text!)
        
        // if it's already selected, deselect and get out
        if highlighted[index] == true {
            highlighted[index] = false
            let indexOfVal = selectedValues.indexOf(val!)
            selectedValues.removeAtIndex(indexOfVal!)
            
            let path = NSIndexPath(forRow: indexIn.row, inSection: indexIn.section)
            indices.removeAll()
            indices.append(path)
            self.collectionView!.reloadItemsAtIndexPaths(indices)
            setupOperatorCells()
            return
        }
            
        // set values for circled item
//        if (cell.label.text == "") {
//            table.tableItems[index] = "\(workingValue!)"
//            hasWorkingVal = false
//                
//            self.collectionView?.reloadData()
//            return
//        }
        
        // is it a month? if not, set up prev/current values
        if (index < 12) {
            return
        }
        else if cell.label.text != "" {
            selectedValues.append(val!)
            highlighted[index] = true
            
            let path = NSIndexPath(forRow: indexIn.row, inSection: indexIn.section)
            indices.removeAll()
            indices.append(path)
            self.collectionView!.reloadItemsAtIndexPaths(indices)
            setupOperatorCells()
        }
        print("Circled cell is \(cell.label.text!)")
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
        let pathBoundingBox = CGPathGetBoundingBox(path)
        
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
                // circle and line stuff
                
                // determine if path was circle
                fitResult = fitCircle(touchedPoints)
                
                // check for points in the middle of the circle
                let hasInside = anyPointsInTheMiddle()
                
                isCircle = fitResult.error <= tolerance && hasInside
                cState = isCircle ? .ended : .failed // fail or end, based on isCircle
                if (isCircle && cState == .ended) {
//                    useCircledCell(fitResult.center)
                }
                
                // so not a circle, must be a line
                
                // get every indexPath on the line
                let coveredIndices = getIndicesForLine(canvas.lines[canvas.lines.endIndex-1])
                for i in 0..<coveredIndices.count {
                    useSelectedCell(coveredIndices[i])
                }
            }
        }
        reset()
    }
    
    func getIndicesForLine(line: Line) -> [NSIndexPath]{
        var result: [NSIndexPath] = []
        var points = line.points
        for i in 1..<points.count {
            let p = points[i]
            let index = self.collectionView!.indexPathForItemAtPoint(p.location)
            if !result.contains(index!) {
                result.append(index!)
            }
        }
        return result
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