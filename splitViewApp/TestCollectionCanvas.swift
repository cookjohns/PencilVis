//
//  ViewController.swift
//  CollectionViewExample
//
//  Created by Justin Hill on 8/2/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import UIKit

class TestCollectionCanvas: UICollectionViewController {

    var table:      Table!
    var detailView: DetailViewController!
    
    private let ReuseIdentifier = "cell" // also set as cell identifier in storyboard
    var canvas = CanvasView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // containing view's background is white
        self.view.backgroundColor = UIColor.whiteColor()
        
        // the container's background should show through the collection view
        self.collectionView?.backgroundColor = UIColor.clearColor()
        
        // register a cell class to be used for a cell
        self.collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifier)
        
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
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReuseIdentifier, forIndexPath: indexPath)
        
        cell.contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 75
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Whenever the container view lays out its subviews, make sure to stretch
        // the canvas over its entire bounds.
        self.canvas.frame = self.view.bounds
        
        // Also, make sure the canvas view is in front of the collection view.
        self.view.bringSubviewToFront(self.canvas)
    }
    
    // MARK: - Touches for CanvasView
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvas.drawTouches(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvas.drawTouches(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canvas.drawTouches(touches, withEvent: event)
        canvas.endTouches(touches, cancel: false)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard let touches = touches else { return }
        canvas.endTouches(touches, cancel: true)
    }
    
    override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
        canvas.updateEstimatedPropertiesForTouches(touches)
    }
}