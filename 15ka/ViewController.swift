//
//  ViewController.swift
//  15ka
//
//  Created by David on 02/03/2016.
//  Copyright © 2016 Revion. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameViewDelegate {

    var gameView: GameView!
    var constWidth: NSLayoutConstraint!
    let widthMultiplier: CGFloat = 0.95
    
    override func viewDidLoad() {
        gameView = GameView(withGameSize: 4)
        gameView.delegate = self
        self.view.addSubview(gameView)
        gameView.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.constWidth = NSLayoutConstraint(item: gameView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: self.widthMultiplier, constant: 0)
        let constHeight = NSLayoutConstraint(item: gameView, attribute: .Height, relatedBy: .Equal, toItem: gameView, attribute: .Width, multiplier: 1.0, constant: 0)
        let constCenterX = NSLayoutConstraint(item: gameView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0)
        let constCenterY = NSLayoutConstraint(item: gameView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0)

        self.view.addConstraints([self.constWidth, constHeight, constCenterX, constCenterY])
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        self.view.removeConstraint(constWidth) // <----
        if toInterfaceOrientation.isPortrait {
            self.constWidth = NSLayoutConstraint(item: gameView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: self.widthMultiplier, constant: 0)
        } else {
            self.constWidth = NSLayoutConstraint(item: gameView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: self.widthMultiplier, constant: 0)
        }
        self.view.addConstraint(self.constWidth) // <----
        //nasledujuci call nic neurobi, remove a add do pola constraintov ano??
        //self.view.setNeedsUpdateConstraints()
    }
    
    func userDidWin(score: Int) {
        let alertController = UIAlertController(title: "Game Won!", message: "You've solved the puzzle in \(score) moves.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Play again!", style: .Default, handler: { _ in
        self.gameView.createRandomArrayOfViews()
        })
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}

