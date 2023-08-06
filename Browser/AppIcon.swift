//
//  AppIcon.swift
//  Roamr
//
//  Created by Aydan Hawken on 6/08/23.
//https://www.avanderlee.com/swift/alternate-app-icon-configuration-in-xcode/

import Foundation
import UIKit

enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon-main"
    case dark = "AppIcon-main2"
    case lightMode = "AppIcon-light"
    case darkBlue = "AppIcon-darkBlue"
    case ghost = "AppIcon-Ghost"
    case lime = "AppIcon-lime"
    case red = "AppIcon-Red"
    
    var id: String { rawValue }
    var iconName: String? {
        switch self {
        case .primary:
            /// `nil` is used to reset the app icon back to its primary icon.
            return nil
        default:
            return rawValue
        }
    }
    
    var description: String {
        switch self {
        case .primary:
            return "Primary"
        case .lightMode:
            return "Light mode"
        case .darkBlue:
            return "darkBlue"
        case .ghost:
            return "Ghost"
            
        case .dark:
            return "Dark"
        case .lime:
            return "Lime"
        case .red:
            return "Red"
        }
        
        var preview: UIImage {
            UIImage(named: rawValue + "") ?? UIImage()
        }
    }
}
