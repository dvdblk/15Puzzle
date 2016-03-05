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
    var number: Int
    var moveableX = false
    var moveableY = false
    var originalFrame: CGRect!
    
    init(_ tempFrame: CGRect, withPosition pos: Position, withNumber num: Int) {
        self.position = pos
        self.number = num
        super.init(frame: tempFrame)
        self.layer.borderWidth = 1
        self.backgroundColor = UIColor.blueColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
        let numberLabel = UILabel()
        numberLabel.textAlignment = .Center
        numberLabel.text = "\(number)"
        numberLabel.textColor = UIColor.whiteColor()
        numberLabel.font = UIFont.systemFontOfSize(25)
        addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        let constCenterX = NSLayoutConstraint(item: numberLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let constCenterY = NSLayoutConstraint(item: numberLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraints([constCenterX, constCenterY])
        self.originalFrame = tempFrame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }
}

