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
    /// color of both title and button body under normal conditions. TODO: change name!
    @IBInspectable var titleColorNormal: UIColor?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setBorderColor(currentTitleColor)
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        if let thecolor = color {
            if state != .disabled {
                setBorderColor(thecolor, for: state)
            } else {
                setBorderColor(thecolor, for: state, animated: true, animationDuration: 0.3)
            }
        } else {
            let defaultColor = titleColor(for: state)
            if state != .disabled {
                setBorderColor(defaultColor!, for: state)
            } else {
                setBorderColor(defaultColor!, for: state, animated: true, animationDuration: 0.3)
            }
        }
        super.setTitleColor(color, for: state)
    }
    
    override func configureButtonStyles() {
        setCornerRadius(cornerRadius)
        setBorderWidth(edgeThickness)
        
        if let normalColor = titleColorNormal {
            setTitleColor(normalColor, for: .normal)
            var hue: CGFloat = 0
            var sat: CGFloat = 0
            var brightness: CGFloat = 0
            normalColor.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: nil)
            let highlightbrightness: CGFloat = 1 - (1 - brightness)/3
            let highlightColor = UIColor(hue: hue, saturation: sat, brightness: highlightbrightness, alpha: 1)
            setTitleColor(highlightColor, for: .highlighted)
            setTitleColor(.systemGray, for: .disabled)
            setBackgroundColor(UIColor(white: 0.5, alpha: 0.05), for: .disabled)
            let normalBackgroundColor = UIColor(hue: hue, saturation: sat, brightness: brightness, alpha: 0.1)
            setBackgroundColor(normalBackgroundColor, for: .normal)
            // setBackgroundColor(UIColor(white: 0.75, alpha: 0.1), for: .normal)
        }
    }
    
}
