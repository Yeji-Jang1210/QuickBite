//
//  Notification+Extension.swift
//  QuickBite
//
//  Created by 장예지 on 8/30/24.
//

import Foundation

extension Notification.Name {
    static let refreshTokenExpired = Notification.Name("refreshTokenExpired")
    static let updateBookmarkCount = Notification.Name("updateBookmarkCount")
    static let pushDetailView = Notification.Name("pushDetailView")
}
