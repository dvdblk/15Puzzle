//
//  SmallView.swift
//  15ka
//
//  Created by David on 02/03/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class SmallView: UIView {

    var position: Position
    var moveableX = false
    var moveableY = false
    var originalFrame: CGRect!
    
    init(_ tempFrame: CGRect, withPosition pos: Position) {
        self.position = pos
        super.init(frame: tempFrame)
        self.originalFrame = tempFrame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeVisible() {
        self.layer.borderWidth = 1
        self.backgroundColor = UIColor.blueColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    override func layoutSubviews() {
        
    }
}

