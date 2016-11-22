//
//  BorderedButton.swift
//  On The Map
//
//  Created by Paul ReFalo on 10/19/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit

// MARK: - BorderedButton: Button

class BorderedButton: UIButton {

    // MARK: Properties
    
    // constants for styling and configuration
    // let darkerBlue = UIColor(red: 0.0, green: 0.298, blue: 0.686, alpha:1.0)
    // let lighterBlue = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    let darkerOrange = UIColor(red: 0.9, green: 0.1275, blue: 0.050, alpha: 1.0)
    let lighterOrange = UIColor(red: 0.9, green: 0.1300, blue: 0.080, alpha: 1.0)

    let titleLabelFontSize: CGFloat = 17.0
    let borderedButtonHeight: CGFloat = 44.0
    let borderedButtonCornerRadius: CGFloat = 4.0
    let phoneBorderedButtonExtraPadding: CGFloat = 14.0
    
    var backingColor: UIColor? = nil
    var highlightedBackingColor: UIColor? = nil
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        themeBorderedButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        themeBorderedButton()
    }
    
    fileprivate func themeBorderedButton() {
        layer.masksToBounds = true
        layer.cornerRadius = borderedButtonCornerRadius
        highlightedBackingColor = darkerOrange  // darkerBlue
        backingColor = lighterOrange // lighterBlue
        backgroundColor = lighterOrange  // lighterBlue
        setTitleColor(UIColor.white, for: UIControlState())
        titleLabel?.font = UIFont.systemFont(ofSize: titleLabelFontSize)
    }
    
    // MARK: Setters
    
    fileprivate func setBackingColor(_ newBackingColor: UIColor) {
        if let _ = backingColor {
            backingColor = newBackingColor
            backgroundColor = newBackingColor
        }
    }
    
    fileprivate func setHighlightedBackingColor(_ newHighlightedBackingColor: UIColor) {
        highlightedBackingColor = newHighlightedBackingColor
        backingColor = highlightedBackingColor
    }
    
    // MARK: Tracking
    
    override func beginTracking(_ touch: UITouch, with withEvent: UIEvent?) -> Bool {
        backgroundColor = highlightedBackingColor
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        backgroundColor = backingColor
    }
    
    override func cancelTracking(with event: UIEvent?) {
        backgroundColor = backingColor
    }
    
    // MARK: Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let extraButtonPadding : CGFloat = phoneBorderedButtonExtraPadding
        var sizeThatFits = CGSize.zero
        sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.height = borderedButtonHeight
        return sizeThatFits
    }
}
