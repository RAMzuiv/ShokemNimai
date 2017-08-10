//
//  CGScene.swift
//  RoyalGame
//
//  Created by Mikkel on 8/7/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import UIKit

class CGScene: UIView {
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = 5
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        UIColor.red.setStroke()
        path.stroke()
    }
}
