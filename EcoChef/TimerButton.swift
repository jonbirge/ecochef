//
//  TimerButton.swift
//

import UIKit

@IBDesignable

class TimerButton: SimpleButton {
    let lightgrey = UIColor(white: 0.9, alpha: 1)
    
    /// Background color for normal state
    @IBInspectable var cornerRadius: CGFloat = 5
    @IBInspectable var titleColorNormal: UIColor?
    
    override func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        super.setTitleColor(color, for: state)
        setBorderColor(color!, for: state)
    }
    
    override func configureButtonStyles() {
        super.configureButtonStyles()
        
        setCornerRadius(cornerRadius)
        
        if let normalColor = titleColorNormal {
            setTitleColor(normalColor, for: .normal)
            var hue: CGFloat = 0
            var sat: CGFloat = 0
            var brightness: CGFloat = 0
            normalColor.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: nil)
            let highlightbrightness: CGFloat = 1 - (1 - brightness)/3
            let highlightColor = UIColor(hue: hue, saturation: sat, brightness: highlightbrightness, alpha: 1)
            setTitleColor(highlightColor, for: .highlighted)
            setBorderColor(highlightColor, for: .highlighted)
        }
        
        setBorderWidth(1.0)
        setBorderColor(lightgrey, for: .disabled, animated: true, animationDuration: 0.1)
        setTitleColor(lightgrey, for: .disabled)
    }
    
}
