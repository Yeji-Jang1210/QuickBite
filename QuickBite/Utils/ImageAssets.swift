//
//  ImageAssets.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit

struct ImageAssets {
    private init(){}
    
    static let person = UIImage(systemName: "person.fill")
    static let lock = UIImage(systemName: "lock.fill")
    static let leftArrow = UIImage(systemName: "chevron.left")
    static let envelope = UIImage(systemName: "envelope.fill")
    static let cake = UIImage(systemName: "birthday.cake.fill")
    static let phone = UIImage(systemName: "iphone.gen1")
    
    static let titleImage = UIImage(named: "titleImage")
    static let defaultProfile = UIImage(named: "default_profile")
    
    //tab icon
    static let main = UIImage(named: "main_tab")
    static let recipes = UIImage(named: "recipe_tab")
    static let profile = UIImage(named: "profile_tab")
}
