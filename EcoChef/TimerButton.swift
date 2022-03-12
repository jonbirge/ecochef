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
        setBorderWidth(width, for: .normal, animated: true, animationDuration: 0.5)
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        guard let thecolor = color else { return }
        
        setBorderColor(thecolor, for: state)
        
        if state == .normal {
            var hue = CGFloat()
            var sat: CGFloat = 0
            var brightness: CGFloat = 0
            
            thecolor.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: nil)
            let highlightBrightness: CGFloat = 1 - (1 - brightness)/3
            let highlightColor = UIColor(hue: hue, saturation: sat, brightness: highlightBrightness, alpha: 1)
            super.setTitleColor(highlightColor, for: .highlighted)
            let backgroundColor = UIColor(hue: hue, saturation: sat, brightness: brightness, alpha: 0.1)
            setBackgroundColor(backgroundColor, for: .normal)
        }
        
        if state == .disabled {
            setBackgroundColor(UIColor(white: 0.5, alpha: 0.025), for: .disabled)
        }
        
        super.setTitleColor(color, for: state)
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
