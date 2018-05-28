//
//  UIColor+RGB.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 20/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

extension UIColor {
    
    func rgb() -> (red: Int, green: Int, blue: Int, alpha: Int)? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        
        if getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            return (red: iRed, green: iGreen, blue: iBlue, alpha: iAlpha)
        }
        
        return nil
    }
    
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
    
    var invertedColor: UIColor {
        let oldCgColor = cgColor
        let numberOfComponents = oldCgColor.numberOfComponents
        
        if numberOfComponents == 1 {
            return UIColor(cgColor: oldCgColor)
        }
        
        let oldComponentColors = oldCgColor.components
        var newComponentColors = [CGFloat](repeating: 0.0, count: numberOfComponents)
        
        var i = numberOfComponents - 1
        newComponentColors[i] = oldComponentColors![i]
        i -= 1
        
        while i >= 0 {
            newComponentColors[i] = 1 - oldComponentColors![i]
            i -= 1
        }
        
        let newCGColor = CGColor(colorSpace: oldCgColor.colorSpace!, components: newComponentColors)!
        let newColor = UIColor(cgColor: newCGColor)
        
        return newColor
    }
    
}
