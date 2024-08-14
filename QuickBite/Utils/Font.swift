//
//  Font.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit


/*
 MaruBuriOTF
 >>>>> MaruBuriot-Regular
 >>>>> MaruBuriot-Light
 >>>>> MaruBuriot-ExtraLight
 >>>>> MaruBuriot-SemiBold
 >>>>> MaruBuriot-Bold
 */

enum FontSize: CGFloat {
    case small = 12
    case smallLarge = 14
    case medium = 16
    case mediumLarge = 18
    case large = 22
    case extraLarge = 28
}

struct Font {
    private init(){}
    
    static func extraLight(_ ofSize: FontSize) -> UIFont {
        return UIFont(name: "MaruBuriot-ExtraLight", size: ofSize.rawValue) ?? .systemFont(ofSize: ofSize.rawValue)
    }
    
    static func light(_ ofSize: FontSize) -> UIFont {
        return UIFont(name: "MaruBuriot-Light", size: ofSize.rawValue) ?? .systemFont(ofSize: ofSize.rawValue)
    }
    
    static func regular(_ ofSize: FontSize) -> UIFont {
        return UIFont(name: "MaruBuriot-Regular", size: ofSize.rawValue) ?? .systemFont(ofSize: ofSize.rawValue)
    }
    
    static func semiBold(_ ofSize: FontSize) -> UIFont {
        return UIFont(name: "MaruBuriot-SemiBold", size: ofSize.rawValue) ?? .boldSystemFont(ofSize: ofSize.rawValue)
    }
    
    static func boldFont(_ ofSize: FontSize) -> UIFont {
        return UIFont(name: "MaruBuriot-Bold", size: ofSize.rawValue) ?? .boldSystemFont(ofSize: ofSize.rawValue)
    }
}
