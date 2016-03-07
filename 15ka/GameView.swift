//
//  GameView.swift
//  15ka
//
//  Created by David on 04/03/2016.
//  Copyright © 2016 Revion. All rights reserved.
//
//
//  source for math stuff: https://www.cs.bham.ac.uk/~mdr/teaching/modules04/java2/TilesSolvability.html

import UIKit
import GameplayKit

typealias Position = (x: Int, y: Int)

protocol GameViewDelegate {
    func userDidWin(moves: Int)
}

class GameView: UIView {

    let gameSize: Int
    let padding: CGFloat
    var delegate: GameViewDelegate!
    
    var singleSmallViewFrame: CGFloat!
    var singleSmallViewFrameWithPadding: CGFloat {
        return singleSmallViewFrame + padding
    }
    var smallViewArray: [SmallView] = []
    
    var blankPosition: Position!
    var selectedView: SmallView?
    var touchPoint: CGPoint!
    var ratio: CGFloat = 0.0
    var moves: Int = 0
    
    init(withGameSize gs: Int, withPadding padd: CGFloat = 2.0) {
        self.gameSize = gs
        self.padding = padd
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare() {
        self.singleSmallViewFrame = (bounds.size.width - self.padding) / CGFloat(gameSize) - padding
        self.blankPosition = (gameSize-1, gameSize-1)
        let pan = UIPanGestureRecognizer(target: self, action: "panGesture:")
        let touch = UITapGestureRecognizer(target: self, action: "touchGesture:")
        addGestureRecognizer(touch)
        addGestureRecognizer(pan)
        self.createRandomArrayOfViews()
    }
    
    func cleanup() {
        self.smallViewArray.removeAll()
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.selectedView = nil
        self.ratio = 0.0
        self.moves = 0
    }
    
    func createRandomArrayOfViews() {
        // returns inversion count for a smallView
        func calculateInversionCount(arrayToCount: [Int]) -> Int {
            func inversionForSmallView(atIndex startIndex: Int) -> Int {
                var inversion: Int = 0
                for i in startIndex..<arrayToCount.count {
                    if arrayToCount[i] < arrayToCount[startIndex] {
                        inversion++
                    }
                }
                return inversion
            }
            var inversionTotal = 0
            for i in 0..<(gameSize*gameSize)-1 {
                inversionTotal += inversionForSmallView(atIndex: i)
            }
            return inversionTotal
        }
        
        // remove previous views
        self.cleanup()
        // shuffle int array
        var numberArray: [Int] = []
        for i in 0..<(gameSize*gameSize)-1 {
            numberArray.append(i+1)
        }
        var shuffledNumberArray = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(numberArray) as! [Int]
        
        // check if inversion count corresponds to gameSize parity (to make puzzle solvable everytime)
        let inversionEven = calculateInversionCount(shuffledNumberArray) % 2 == 0
        let widthEven = gameSize % 2 == 0
        if  (!widthEven && !inversionEven) || (widthEven && !inversionEven) {
            swap(&shuffledNumberArray[0], &shuffledNumberArray[1])
        }
        
        // create smallViews with solvable number sequence
        for j in 0..<gameSize {
            for i in 0..<gameSize {
                // removes last smallView (creates blank spot)
                if j==gameSize-1 && i==gameSize-1 { break }
                let tempFrame = self.frameForPosition((i,j))
                let smallView = SmallView(tempFrame, withPosition: (i,j), withNumber: shuffledNumberArray[self.indexForPosition((i,j))])
                self.smallViewArray.append(smallView)
                addSubview(smallView)
            }
        }
    }
    
    func checkIfCorrectSequence() {
        var tempCorrectArray: [Int] = []
        var tempCurrentArray: [Int] = []
        for i in 1..<gameSize*gameSize {
            tempCorrectArray.append(i)
        }
        self.smallViewArray.forEach({ tempCurrentArray.append($0.number) })
        
        if tempCorrectArray == tempCurrentArray {
            self.delegate!.userDidWin(self.moves)
        }
    }
    
    func frameForPosition(pos: Position) -> CGRect {
        let orig: CGPoint =  CGPoint(x: CGFloat(pos.0)*(self.singleSmallViewFrame)+CGFloat(pos.0+1)*self.padding, y: CGFloat(pos.1)*(self.singleSmallViewFrame)+CGFloat(pos.1+1)*self.padding)
        let frame = CGRect(origin: orig, size: CGSize(width: self.singleSmallViewFrame, height: self.singleSmallViewFrame))
        return frame
    }
    
    func indexForPosition(pos: Position) -> Int {
        return pos.x + (pos.y * gameSize)
    }
    
    func handleTap(rec: UIGestureRecognizer) {
        if let tempSelectedView = hitTest(rec.locationInView(self), withEvent: nil) as? SmallView {
            let posX = tempSelectedView.position.x
            let posY = tempSelectedView.position.y
            let blankX = self.blankPosition.x
            let blankY = self.blankPosition.y
            self.touchPoint = rec.locationInView(tempSelectedView)
            if (posX+1 == blankX || posX-1 == blankX) && posY == blankY {
                tempSelectedView.moveableX = true
            } else if (posY+1 == blankY || posY-1 == blankY) && posX == blankX {
                tempSelectedView.moveableY = true
            }
            self.selectedView = tempSelectedView
        }
    }
    
    func handleFinalPosition(tempSelectedView: SmallView) {
        UIView.animateWithDuration(0.2, animations: {
            tempSelectedView.frame = self.frameForPosition(self.blankPosition)
        })
        // change smallViewArray ordering if frame was moved on Y axis only
        if tempSelectedView.moveableY {
            for i in 0..<self.smallViewArray.count {
                if self.smallViewArray[i].number == tempSelectedView.number {
                    self.smallViewArray.removeAtIndex(i)
                    var newIndex: Int
                    if self.ratio >= 0 {
                        newIndex = i+self.gameSize-1
                    } else {
                        newIndex = i-self.gameSize+1
                    }
                    self.smallViewArray.insert(tempSelectedView, atIndex: newIndex)
                    break;
                }
            }
        }
        
        // swap blankPosition with selected smallView position and check if player has won if new blankPos is in the bottom right corner
        let tempBlankPos = self.blankPosition
        self.blankPosition = tempSelectedView.position
        tempSelectedView.position = tempBlankPos
        tempSelectedView.originalFrame = tempSelectedView.frame
        self.moves++
        
        if self.blankPosition.x == self.gameSize-1 && self.blankPosition.y == self.gameSize-1 {
            self.checkIfCorrectSequence()
        }

    }
    
    func panGesture(rec: UIPanGestureRecognizer) {
        switch rec.state {
        case .Began:
            // test if close to blank space then set moveable by X/Y
            self.handleTap(rec)
        case .Changed:
            if let tempSelectedView = self.selectedView as SmallView? {
                let globalOffset = rec.locationInView(self)
                var newFrame: CGRect = tempSelectedView.frame
                // if moveable only on X axis ...
                if tempSelectedView.moveableX {
                    self.ratio = (globalOffset.x-touchPoint.x-tempSelectedView.originalFrame.origin.x)/self.singleSmallViewFrameWithPadding
                    if self.blankPosition.x > tempSelectedView.position.x {
                        self.ratio = max(min(1, ratio), 0)
                    } else {
                        self.ratio = max(min(0, ratio), -1)
                    }
                    newFrame = CGRect(origin: CGPoint(x: tempSelectedView.originalFrame.origin.x + self.ratio*self.singleSmallViewFrameWithPadding, y: tempSelectedView.frame.origin.y), size: tempSelectedView.frame.size)
                // if moveable only on Y axis
                } else if tempSelectedView.moveableY {
                    self.ratio = (globalOffset.y-touchPoint.y-tempSelectedView.originalFrame.origin.y)/self.singleSmallViewFrameWithPadding
                    if self.blankPosition.y > tempSelectedView.position.y {
                        self.ratio = max(min(1, ratio), 0)
                    } else {
                        self.ratio = max(min(0, ratio), -1)
                    }
                    newFrame = CGRect(origin: CGPoint(x: tempSelectedView.frame.origin.x, y: tempSelectedView.originalFrame.origin.y + self.ratio*self.singleSmallViewFrameWithPadding), size: tempSelectedView.frame.size)
                }
                tempSelectedView.frame = newFrame
            }
        case .Ended:
            if let tempSelectedView = self.selectedView as SmallView? {
                // if frame is moved more than 30% of the way (either up/down or to the sides) animate frame to its new position
                if abs(self.ratio) >= 0.3 {
                self.handleFinalPosition(tempSelectedView)
                    // otherwise move to original frame (initial position)
                } else if self.ratio != 0 {
                    UIView.animateWithDuration(0.15, animations: {
                        tempSelectedView.frame = self.frameForPosition(tempSelectedView.position)
                    })
                }
                // reset movement info
                tempSelectedView.moveableX = false
                tempSelectedView.moveableY = false
                self.ratio = 0
            }
        default:
            break
        }
    }
    
    func touchGesture(rec: UITapGestureRecognizer) {
        self.handleTap(rec)
        if let tempSelectedView = self.selectedView as SmallView? {
            let moveable = tempSelectedView.moveableX || tempSelectedView.moveableY
            if moveable {
                // set direction if moving vertically...
                if self.blankPosition.y < tempSelectedView.position.y { self.ratio = -1 }
                self.handleFinalPosition(tempSelectedView)
                tempSelectedView.moveableX = false
                tempSelectedView.moveableY = false
                self.ratio = 0
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.smallViewArray.count == 0 {
            prepare()
        }
    }
}
