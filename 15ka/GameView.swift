//
//  GameView.swift
//  15ka
//
//  Created by David on 04/03/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit
import GameplayKit

typealias Position = (x: Int, y: Int)

class GameView: UIView {

    let gameSize: Int
    let padding: CGFloat
    
    var singleFrameOrigin: CGFloat!
    var singleFrameOriginWithPadding: CGFloat {
        return singleFrameOrigin + padding
    }
    var smallViewArray: [SmallView] = []
    
    var blankPosition: Position!
    var selectedView: SmallView?
    var touchPoint: CGPoint!
    var ratio: CGFloat = 0.0
    
    init(withGameSize gs: Int, withPadding padd: CGFloat = 2.0) {
        self.gameSize = gs
        self.padding = padd
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare() {
        self.singleFrameOrigin = (bounds.size.width - self.padding) / CGFloat(gameSize) - padding
        self.blankPosition = (gameSize-1, gameSize-1)
        let pan = UIPanGestureRecognizer(target: self, action: "panGesture:")
        addGestureRecognizer(pan)
        self.randomArrayOfViews()
    }
    
    func randomArrayOfViews() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        var numberArray: [Int] = []
        for i in 0..<(gameSize*gameSize)-1 {
            numberArray.append(i+1)
        }
        let shuffledNumberArray = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(numberArray) as! [Int]
        for j in 0..<gameSize {
            for i in 0..<gameSize {
                if j==gameSize-1 && i==gameSize-1 { break } // removes last
                let tempFrame = self.frameForPosition((i,j))
                let smallView = SmallView(tempFrame, withPosition: (i,j), withNumber: shuffledNumberArray[self.indexForPosition((i,j))])
                self.smallViewArray.append(smallView)
                addSubview(smallView)
            }
        }
    }
    
    func checkIfCorrect() {
        var tempCorrectArr: [Int] = []
        var tempCurrentArr: [Int] = []
        for i in 1..<gameSize*gameSize {
            tempCorrectArr.append(i)
        }
        for i in 0..<self.smallViewArray.count {
            tempCurrentArr.append(self.smallViewArray[i].number)
        }
        if tempCorrectArr == tempCurrentArr {
            print("same!!!!")
        } else {
            print("nope")
        }
    }
    
    func frameForPosition(pos: Position) -> CGRect {
        let orig: CGPoint =  CGPoint(x: CGFloat(pos.0)*(self.singleFrameOrigin)+CGFloat(pos.0+1)*self.padding, y: CGFloat(pos.1)*(self.singleFrameOrigin)+CGFloat(pos.1+1)*self.padding)
        let frame = CGRect(origin: orig, size: CGSize(width: self.singleFrameOrigin, height: self.singleFrameOrigin))
        return frame
    }
    
    func indexForPosition(pos: Position) -> Int {
        return pos.x + (pos.y * gameSize)
    }
    
    func panGesture(rec: UIPanGestureRecognizer) {
        switch rec.state {
        case .Began:
            // test if close to blank space then set moveable by X/Y
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
        case .Changed:
            // move in one axis only
            if let tempSelectedView = self.selectedView as SmallView? {
                let globalOffset = rec.locationInView(self)
                var newFrame: CGRect = tempSelectedView.frame
                if tempSelectedView.moveableX {
                    self.ratio = (globalOffset.x-touchPoint.x-tempSelectedView.originalFrame.origin.x)/self.singleFrameOriginWithPadding
                    if self.blankPosition.x > tempSelectedView.position.x {
                        self.ratio = max(min(1, ratio), 0)
                    } else {
                        self.ratio = max(min(0, ratio), -1)
                    }
                    newFrame = CGRect(origin: CGPoint(x: tempSelectedView.originalFrame.origin.x + self.ratio*self.singleFrameOriginWithPadding, y: tempSelectedView.frame.origin.y), size: tempSelectedView.frame.size)
                } else if tempSelectedView.moveableY {
                    self.ratio = (globalOffset.y-touchPoint.y-tempSelectedView.originalFrame.origin.y)/self.singleFrameOriginWithPadding
                    if self.blankPosition.y > tempSelectedView.position.y {
                        self.ratio = max(min(1, ratio), 0)
                    } else {
                        self.ratio = max(min(0, ratio), -1)
                    }
                    newFrame = CGRect(origin: CGPoint(x: tempSelectedView.frame.origin.x, y: tempSelectedView.originalFrame.origin.y + self.ratio*self.singleFrameOriginWithPadding), size: tempSelectedView.frame.size)
                }
                tempSelectedView.frame = newFrame
            }
        case .Ended:
            if let tempSelectedView = self.selectedView as SmallView? {
                if abs(self.ratio) >= 0.3 {
                    UIView.animateWithDuration(0.2, animations: {
                        tempSelectedView.frame = self.frameForPosition(self.blankPosition)
                    })
                    
                    if tempSelectedView.moveableY {
                        for i in 0..<self.smallViewArray.count {
                            if self.smallViewArray[i].number == tempSelectedView.number {
                                self.smallViewArray.removeAtIndex(i)
                                var newIndex: Int
                                if self.ratio > 0 {
                                    newIndex = i+self.gameSize-1
                                } else {
                                    newIndex = i-self.gameSize+1
                                }
                                self.smallViewArray.insert(tempSelectedView, atIndex: newIndex)
                                break;
                            }
                        }
                    }
                    
                    let tempBlankPos = self.blankPosition
                    self.blankPosition = tempSelectedView.position
                    tempSelectedView.position = tempBlankPos
                    
                    tempSelectedView.originalFrame = tempSelectedView.frame
                    if self.blankPosition.x == self.gameSize-1 && self.blankPosition.y == self.gameSize-1 {
                        self.checkIfCorrect()
                    }
                } else if self.ratio != 0 {
                    UIView.animateWithDuration(0.15, animations: {
                        tempSelectedView.frame = self.frameForPosition(tempSelectedView.position)
                    })
                }
                tempSelectedView.moveableX = false
                tempSelectedView.moveableY = false
                self.ratio = 0
            }
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.smallViewArray.count == 0 {
            prepare()
        }
    }
}
