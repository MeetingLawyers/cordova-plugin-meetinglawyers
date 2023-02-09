//
//  UIColor+Luminance.swift
//  Whitelabel
//
//  Created by Manel MeetingLawyers on 5/11/21.
//

import Foundation
import UIKit

extension UIColor {
    var luminance: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
    }

    var isLight: Bool {
        return luminance >= 0.7
    }
}
