//
//  GameView.swift
//  15ka
//
//  Created by David on 04/03/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class GameView: UIView {

    let gameSize: Int = 5
    var smallViewArray: [SmallView?] = []

    func prepare() {
        let frameOrigin = bounds.size.width / CGFloat(gameSize)
        print(frameOrigin)
        let pan = UIPanGestureRecognizer(target: self, action: "panGesture:")
        addGestureRecognizer(pan)
        
        for i in 0..<gameSize {
            for j in 0..<gameSize {
                let orig: CGPoint =  CGPoint(x: CGFloat(i)*frameOrigin, y: CGFloat(j)*frameOrigin)
                let smallView = SmallView(frame: CGRect(origin: orig, size: CGSize(width: frameOrigin, height: frameOrigin)), withPosition: (i, j))
                smallView.makeVisible()
                self.smallViewArray.append(smallView)
                addSubview(smallView)
            }
        }
        self.smallViewArray.last?.map({$0.removeFromSuperview()})
        self.smallViewArray.removeLast()
    }
    
    func panGesture(rec: UIPanGestureRecognizer) {
        switch rec.state {
        case .Began:
            let selectedView = hitTest(rec.locationInView(self), withEvent: nil) as? SmallView
            print(selectedView?.myPosition)
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
