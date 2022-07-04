//
//  TimerButton.swift
//

import UIKit
import SimpleButton

@IBDesignable
class TimerButton: SimpleButton {
  @IBInspectable var cornerRadius: CGFloat = 7
  @IBInspectable var edgeThickness: CGFloat = 1.5
  @IBInspectable var ringColor: UIColor = .lightGray
  @IBInspectable var dialColor: UIColor = .orange
  @IBInspectable var backColor: UIColor = .white
  @IBInspectable var timeColor: UIColor = .black
  var setTime: Float = 10  // fractional minutes
  var curTime: Float = 7.5  // fractional minutes counting up
  
  // TODO: switch to properties
  
  func curTime (_ t: Float) {
    self.curTime = t
    let min = Int(floor(t))
    let sec = Int(round((t - Float(min))*60))
    let timeStr = padString(min) + ":" + padString(sec)
    self.setTitle(timeStr, for: .normal)
    setNeedsDisplay()
  }
  
  func setTime (_ t: Float) {
    self.setTime = t
  }
  
  override func draw(_ rect: CGRect) {
    guard let gc = UIGraphicsGetCurrentContext() else {
      return
    }
    let ringRect = rect.insetBy(dx: 2, dy: 2)
    gc.setFillColor(backColor.cgColor)
    gc.fill(ringRect)
    let radius = min(rect.width, rect.height) / 2.0 * 0.75
    let center = CGPoint(x: rect.midX, y: rect.midY)
    gc.setStrokeColor(dialColor.cgColor)
    gc.setLineWidth(2.0)
    gc.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2*Float.pi), clockwise: false)
    gc.strokePath()
    if setTime > 0 {
      let angle = CGFloat(2.0*Float.pi*curTime/setTime)
      gc.setStrokeColor(ringColor.cgColor)
      gc.setLineWidth(7.0)
      gc.setLineCap(.round)
      let startang = CGFloat(-3/2*Float.pi)
      gc.addArc(center: center, radius: radius, startAngle: startang, endAngle: startang+angle, clockwise: false)
      gc.strokePath()
    }
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setBorderColor(currentTitleColor)
  }
  
  /// animate change in border thickness
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
    
    // set colors
    setBorderColor(thecolor, for: state, animated: true, animationDuration: 0.25)
    var hue: CGFloat = 0
    var sat: CGFloat = 0
    var brightness: CGFloat = 0
    thecolor.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: nil)
    setBackgroundColor(backColor, for: state)
    super.setTitleColor(color, for: state)
    
    // set related highlight color if .normal
    if state == .normal {
      let highlightBrightness: CGFloat = brightness/2
      let highlightColor = UIColor(hue: hue, saturation: sat, brightness: highlightBrightness, alpha: 1)
      super.setTitleColor(highlightColor, for: .highlighted)
      super.setBackgroundColor(backColor, for: .highlighted)
    }
  }
  
  override func configureButtonStyles() {
    print("configureButtonStyles()")
    
    // Set IBInspectable stuff
    setCornerRadius(cornerRadius)
    setBorderWidth(edgeThickness)
    
    // Invoke TimerButton title color function
    setTitleColor(timeColor, for: .normal)
    setTitleColor(.systemGray, for: .disabled)
  }
  
  private func padString (_ x: Int) -> String {
    let xStr = String(x)
    if x < 10 {
      return "0" + xStr
    } else {
      return xStr
    }
  }
  
}
