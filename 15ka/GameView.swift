//
//  GameView.swift
//  15ka
//
//  Created by David on 04/03/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

typealias Position = (x: Int, y: Int)

class GameView: UIView {

    let gameSize: Int = 5
    let padding: CGFloat = 2
    
    var singleFrameOrigin: CGFloat!
    var singleFrameOriginWithPadding: CGFloat {
        return singleFrameOrigin + padding
    }
    var smallViewArray: [SmallView?] = []
    
    var blankPosition: Position!
    var selectedView: SmallView?
    var touchPoint: CGPoint!
    var ratio: CGFloat = 0.0

    func prepare() {
        self.singleFrameOrigin = (bounds.size.width - self.padding) / CGFloat(gameSize) - padding
        self.blankPosition = (gameSize-1, gameSize-1)
        let pan = UIPanGestureRecognizer(target: self, action: "panGesture:")
        addGestureRecognizer(pan)
        
        for i in 0..<gameSize {
            for j in 0..<gameSize {
                let tempFrame = self.frameForPosition((i,j))
                let smallView = SmallView(tempFrame, withPosition: (i,j), withNumber: i+1+(j*gameSize))
                self.smallViewArray.append(smallView)
                addSubview(smallView)
            }
        }
        // remove "blank one"
        self.smallViewArray.last?.map({$0.removeFromSuperview()})
        self.smallViewArray.removeLast()
    }
    
    func frameForPosition(pos: Position) -> CGRect {
        let orig: CGPoint =  CGPoint(x: CGFloat(pos.0)*(self.singleFrameOrigin)+CGFloat(pos.0+1)*self.padding, y: CGFloat(pos.1)*(self.singleFrameOrigin)+CGFloat(pos.1+1)*self.padding)
        let frame = CGRect(origin: orig, size: CGSize(width: self.singleFrameOrigin, height: self.singleFrameOrigin))
        return frame
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
                tempSelectedView.moveableX = false
                tempSelectedView.moveableY = false
                if abs(self.ratio) >= 0.25 {
                    UIView.animateWithDuration(0.2, animations: {
                        tempSelectedView.frame = self.frameForPosition(self.blankPosition)
                    })
                    let tempPos = blankPosition
                    blankPosition = tempSelectedView.position
                    tempSelectedView.position = tempPos
                    tempSelectedView.originalFrame = tempSelectedView.frame
                } else if self.ratio != 0 {
                    UIView.animateWithDuration(0.15, animations: {
                        tempSelectedView.frame = self.frameForPosition(tempSelectedView.position)
                    })
                }
                self.ratio = 0
            }
        default:
            break
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if smallViewArray.count == 0 {
            prepare()
        }
    }
}
