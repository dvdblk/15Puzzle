//
//  GameView.swift
//  15ka
//
//  Created by David on 04/03/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

typealias Position = (Int, Int)

class GameView: UIView {

    let gameSize: Int = 5
    let padding: CGFloat = 2
    
    var singleFrameOrigin: CGFloat!
    var smallViewArray: [SmallView?] = []
    
    var blankPosition: Position!
    var selectedView: SmallView?
    var touchPoint: CGPoint!

    func prepare() {
        self.singleFrameOrigin = (bounds.size.width - self.padding) / CGFloat(gameSize) - padding
        self.blankPosition = (gameSize-1, gameSize-1)
        let pan = UIPanGestureRecognizer(target: self, action: "panGesture:")
        addGestureRecognizer(pan)
        
        for i in 0..<gameSize {
            for j in 0..<gameSize {
                let tempFrame = self.frameForPosition((i,j))
                let smallView = SmallView(tempFrame, withPosition: (i,j))
                smallView.makeVisible()
                self.smallViewArray.append(smallView)
                addSubview(smallView)
            }
        }
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
            // test if close to blank space then moveable by X/Y
            if let tempSelectedView = hitTest(rec.locationInView(self), withEvent: nil) as? SmallView {
                let posX = tempSelectedView.position.0
                let posY = tempSelectedView.position.1
                let blankX = self.blankPosition.0
                let blankY = self.blankPosition.1
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
            if let tempSelectedView = self.selectedView {
                if tempSelectedView.moveableX {
                    if self.blankPosition.0 > tempSelectedView.position.0 {
                        let globalOffset = rec.locationInView(self)
                        var ratio = (globalOffset.x - self.touchPoint.x) / (self.singleFrameOrigin + padding)
                        ratio = max(min(1, ratio), 0)
                        var newFrame = tempSelectedView.frame
                        newFrame.origin.x += newFrame.origin.x*ratio
                        tempSelectedView.frame = newFrame
                    }
                } else if tempSelectedView.moveableY {
                    print("Y")
                }
            }
        case .Ended:
            selectedView?.moveableX = false
            selectedView?.moveableY = false
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
