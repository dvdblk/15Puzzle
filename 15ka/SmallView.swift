//
//  SmallView.swift
//  15ka
//
//  Created by David on 02/03/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class SmallView: UIView {

    var myPosition: (Int, Int)
    
    init(frame: CGRect, withPosition pos: (Int, Int)) {
        self.myPosition = pos
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeBlank() {
        
    }
    
    func makeVisible() {
        self.layer.borderWidth = 1
        self.backgroundColor = UIColor.blueColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    override func layoutSubviews() {
        
    }
}

