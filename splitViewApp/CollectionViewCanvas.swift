//
//  ViewController.swift
//  CollectionViewExample
//
//  Created by John Cook on 8/2/16.
//  Thanks to Justin Hill for direction.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class CollectionViewCanvas: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - VARIABLES
    
    var table:      Table!
    var detailView: DetailViewController!
    var textView:     UITextView!
    var clearButton:  UIButton!
    var workingData: [Double]! = []
    private let ReuseIdentifier = "cell" // also set as cell identifier in storyboard
    var cellLoadCount: Int = 0
    
    var canvas = CanvasView()
    var visualizeAzimuth = false
    
    // MARK: - FUNCTIONS
    
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
        
        // make the canvas' background clear (we want to draw on top of
        // the collection view.)
        self.canvas.backgroundColor = UIColor.clearColor()
        
        // add the canvas to the container. This essentially gives us:
        //                container
        //                /       \
        //     collectionview    canvas
        //
        // the container's subviews array is now [collectionView, canvas]. The
        // order in which they'll be drawn goes: bottom <-----------> top, i.e.
        // the first item in the array is the bottom view and the last item in
        // the array is the top view.
        self.view.addSubview(self.canvas)
        
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
        textView = UITextView(frame: CGRectMake(100, 755.0, 300.0, 150.0))
        textView.textAlignment      = NSTextAlignment.Left
        textView.textColor          = UIColor.blueColor()
        textView.backgroundColor    = UIColor(white: 0.9, alpha: 1)
        textView.layer.borderColor  = UIColor.grayColor().CGColor
        textView.layer.borderWidth  = 2
        textView.layer.cornerRadius = 8
        self.view.addSubview(textView)

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
        
        // add long press gesture recognizer to simulate circling with pencil
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        self.view.addGestureRecognizer(longPress)
        
//        // add double tap gesture recognizer so things don't crash when double tapping
//        // set up tap recognizer for double taps (need discrete gesture for each view)
//        let tapCanvas = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
//        tapCanvas.numberOfTapsRequired = 2
//        self.canvas.addGestureRecognizer(tapCanvas)
//        let tapCollection = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
//        tapCollection.numberOfTapsRequired = 2
//        self.collectionView!.addGestureRecognizer(tapCollection)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Whenever the container view lays out its subviews, make sure to stretch
        // the canvas over its entire bounds.
        self.canvas.frame = self.view.bounds
        
        // Also, make sure the canvas view is in front of the collection view and on-screen controls
//        self.view.bringSubviewToFront(self.canvas)
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
            let indexPath = self.collectionView!.indexPathForItemAtPoint(point)
            if indexPath != nil {
                let cell = self.collectionView!.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
                let units = Double(cell.label.text!)
                if let val = units {
                    textView.insertText("\(val)\n")
                }
                workingData.append(units!)
            }
        }
    }
    
    func findCircledCell(center: CGPoint) {
        // walk through the image views and see if the center of the drawn circle was over one of the views
        print(self.collectionView!.indexPathForItemAtPoint(center)?.row)
        let indexPath = self.collectionView!.indexPathForItemAtPoint(center)
        if indexPath != nil {
            let cell = self.collectionView!.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
            let units = unitsForMonth(cell.label.text!)
            textView.insertText("\(units)\n")
            workingData.append(units)
            print("Circled cell is \(cell.label.text), \(units) units.")
        }
    }
    
//    func circled(c: CircleGestureRecognizer) {
    func circled() {
        if (cState == .Ended) {
            print("Made a circle")
//            findCircledCell(c.fitResult.center)
            findCircledCell(fitResult.center)
        }
        
        //            if (cState == .Began) {
        //                circlerDrawer.clear()
        //            }
        //            if (cState == .Changed) {
        //                circlerDrawer.updatePath(path)
        //            }
        //            if (cState == .Ended || cState == .Failed || cState == .Cancelled) {
        //                circlerDrawer.updateFit(fitResult, madeCircle: isCircle)
        //            }
    }
    
    func unitsForMonth(month: String) -> Double {
        let index = table.monthsIndexWithMatchingName(month)
        return table.unitsSold[index]
    }
    
//    func doubleTap() {
//        print("double tap recognized")
//    }
    
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
        let isMonth = index % 5 == 0 && index != 65 ? true : false
        
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
        
        if cellLoadCount < 70 {
            // set blue baackgrounds
            if index != 0 && index != 70 && (index < 5 || index % 5 == 0) {
                cell.contentView.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1)
            }
            cellLoadCount += 1
        }
        else {
            // catch for top line
            if index < 5 {
                return cell
            }
            // if cell is (going to be) active month label, set blue background
            if (isMonth && table.isActive(index)) {
                cell.contentView.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1)
            }
                // if cell is inactive month label, set background to gray color
            else if (isMonth && !table.isActive(index)) {
                cell.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1)
                cell.label.textColor = UIColor.lightGrayColor()
            }
                //  if cell is active, set white background and black text (or top left cell)
            else if (table.isActive(index)) {
                cell.contentView.backgroundColor = UIColor.whiteColor()
            }
                // cell is inactive, set white background and gray text
            else if (!table.isActive(index)) {
                cell.contentView.backgroundColor = UIColor.whiteColor()
                cell.label.textColor = UIColor.lightGrayColor()
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.item
        let isMonth = index % 5 == 0 && index != 65 ? true : false
        
        // check for valid selection box
        if (index < 5) {
            return
        }
        
        // create array for storing index path's to be updated
        var indices = [indexPath]
        
        // get month index
        let selectedMonth  = (index / 5) - 1
        
        // if the selected cell is a month
        if (isMonth) {
            // if cell is (going to be) active, make it inactive, then delete item in table and change cell color
            if table.isActive(index) {
                table.deactivate(index)
            }
                // if cell is inactive, make it active, then add item back to table and change cell color
            else {
                table.activate(index)
            }
            // add index paths of weeks in selected month
            for i in 1...4 {
                let path = NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section)
                indices.append(path)
            }
        }
            // otherwise, selected cell is a week
        else {
            // if selected month is inactive, break
            if !table.isActive(selectedMonth) {
                return
            }
            
            let selectedAmount = Double(table.tableItems[indexPath.item])
            
            // check for empty cell
            if selectedAmount == nil {
                return
            }
            
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
        self.collectionView!.reloadItemsAtIndexPaths(indices)
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
    
    // MARK: - Touches for CanvasView
    
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
            cState = .Failed // cancel the gesture if more than one finger is involved
        }
        cState = .Began
        
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
        if cState == .Failed {
            return
        }
        
        let window = view?.window
        if let touches = touches as? Set<UITouch>, loc = touches.first?.locationInView(window) {
            touchedPoints.append(loc)
            CGPathAddLineToPoint(path, nil, loc.x, loc.y)
            cState = .Changed
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvas.drawTouches(touches, withEvent: event)
        canvas.endTouches(touches, cancel: false)
        if (touches.first!.type == .Stylus) {
            let intersection = canvas.getIntersection()
            if intersection.x >= 0 {
                print("Intersection x at \(intersection.x)")
                let indexPath = collectionView?.indexPathForItemAtPoint(intersection)
                if indexPath != nil {
                    self.collectionView(collectionView!, didSelectItemAtIndexPath: indexPath!)
                }
            }
        }
        
        // cirlce stuff
        // figure out if path was circle
        fitResult = fitCircle(touchedPoints)
        
        // check for points in the middle of the circle
        let hasInside = anyPointsInTheMiddle()
        
        _ = calculateBoundingOverlap()
        isCircle = fitResult.error <= tolerance && !hasInside && calculateBoundingOverlap() > (1-tolerance)
        cState = isCircle ? .Ended : .Failed // fail or end, based on isCircle
        if (cState == .Ended) {
            circled()
        }
        reset()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touches = touches else { return }
        canvas.endTouches(touches, cancel: true)
        cState = .Cancelled
    }
    
    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
        canvas.updateEstimatedPropertiesForTouches(touches)
    }
    
    // MARK: - Circle Gesture Stuff
    
    private var touchedPoints = [CGPoint]() // point history
    var fitResult = CircleResult()  // info about how circle-like the path is
    var tolerance: CGFloat = 0.2    // "perfect circle" tolerance
    var isCircle = false
    var path = CGPathCreateMutable()
    enum circleState {
        case Began
        case Ended
        case Cancelled
        case Changed
        case Failed
        case Possible
    }
    var cState : circleState = .Ended
    
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
        cState = .Possible
    }
}