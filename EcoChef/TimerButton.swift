//
//  TimerButton.swift
//

import UIKit

@IBDesignable

class TimerButton: SimpleButton {
    
    /// Background color for normal state
    @IBInspectable var normalBackgroundColor: UIColor?
    @IBInspectable var highlightBackgroundColor: UIColor?
    @IBInspectable var titleColorNormal: UIColor?
    @IBInspectable var cornerRadius: CGFloat = 5
    
    override func configureButtonStyles() {
        super.configureButtonStyles()
        
        setCornerRadius(cornerRadius)
        
        if let backgroundColorNormal = normalBackgroundColor {
            setBackgroundColor(backgroundColorNormal, for: .normal)
        }
        if let backgroundColorHighlight = highlightBackgroundColor {
            setBackgroundColor(backgroundColorHighlight, for: .highlighted)
        }
        
        let lightgrey = UIColor(white: 0.9, alpha: 1)
        setBackgroundColor(lightgrey, for: .disabled, animated: true, animationDuration: 0.1)
        setTitleColor(UIColor.white, for: .disabled)
        
        if let titleColorNormal = titleColorNormal {
            setTitleColor(titleColorNormal, for: .normal)
        }
    }
    
}
