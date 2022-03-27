//
//  TimerButton.swift
//

import UIKit
import SimpleButton

@IBDesignable

class TimerButton: SimpleButton {
    /// radius of border corners
    @IBInspectable var cornerRadius: CGFloat = 7
    /// line thickness of border
    @IBInspectable var edgeThickness: CGFloat = 1.5

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setBorderColor(currentTitleColor)
    }
    
    /// automatically animate change in border thickness
    func setEdgeThickness(_ width: CGFloat) {
        edgeThickness = width
        setBorderWidth(width, for: .normal, animated: true, animationDuration: 0.25)
    }
    
    /// set title color and matching background and highlight colors
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        guard let thecolor = color else {
            print("TimerButton: nil color given to setTitleColor")
            return
        }
        
        setBorderColor(thecolor, for: state, animated: true, animationDuration: 0.25)
        
        var hue = CGFloat()
        var sat: CGFloat = 0
        var brightness: CGFloat = 0
        thecolor.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: nil)
        let backgroundColor = UIColor(hue: hue, saturation: sat, brightness: brightness, alpha: 0.15)
        setBackgroundColor(backgroundColor, for: state, animated: true, animationDuration: 1)
        
        super.setTitleColor(color, for: state)

        // set related highlight color if .normal
        if state == .normal {
            let highlightBrightness: CGFloat = brightness/2
            let highlightColor = UIColor(hue: hue, saturation: sat, brightness: highlightBrightness, alpha: 1)
            let highlightBackground = UIColor(hue: hue, saturation: sat, brightness: highlightBrightness, alpha: 0.15)
            super.setTitleColor(highlightColor, for: .highlighted)
            super.setBackgroundColor(highlightBackground, for: .highlighted, animated: true, animationDuration: 0.15)
        }
    }
    
    override func configureButtonStyles() {
        // Set IBInspectable stuff
        setCornerRadius(cornerRadius)
        setBorderWidth(edgeThickness)
        
        // Invoke TimerButton title color function
        setTitleColor(titleColor(for: .normal), for: .normal)
        setTitleColor(.systemGray, for: .disabled)
    }
    
}
