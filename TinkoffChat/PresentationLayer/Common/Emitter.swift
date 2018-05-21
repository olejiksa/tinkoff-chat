//
//  Emitter.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/05/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class Emitter {
    
    private weak var superView: UIView?
    private var particleEmitter = CAEmitterLayer()
    private var longPressHandler = UILongPressGestureRecognizer()
    
    init(view: UIView) {
        superView = view
        
        longPressHandler = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        superView?.addGestureRecognizer(longPressHandler)
    }
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch longPressHandler.state {
        case .began:
            createTinkoffArms()
        case .changed:
            particleEmitter.emitterPosition = sender.location(in: superView)
        case .ended:
            particleEmitter.removeFromSuperlayer()
        default:
            break
        }
    }
    
    private func createTinkoffArms() {
        superView?.endEditing(true)
        
        particleEmitter.emitterPosition = longPressHandler.location(in: superView)
        particleEmitter.emitterShape = kCAEmitterLayerCircle
        particleEmitter.emitterSize = CGSize(width: 50, height: 50)
        
        let cell = CAEmitterCell()
        
        cell.birthRate = 10
        cell.contents = UIImage(named: "TinkoffArms")?.cgImage
        cell.contentsScale = 5
        cell.lifetime = 3
        cell.lifetimeRange = 1
        cell.color = #colorLiteral(red: 0.9518912435, green: 0.8770589232, blue: 0.0947964713, alpha: 1)
        cell.velocity = 150
        cell.velocityRange = 100
        cell.emissionLongitude = -.pi * 0.8
        cell.emissionRange = .pi / 5
        cell.spin = 3
        cell.spinRange = 2
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.10
        cell.yAcceleration = 30.0
        cell.xAcceleration = -5
        
        particleEmitter.emitterCells = [cell]
        
        superView?.layer.addSublayer(particleEmitter)
    }
    
}
