//
//  NotchScreenSelectionPreferences.swift
//  Wnotch
//
//  Created by M on 6/27/26.
//

import Foundation

struct NotchScreenSelectionPreferences: Equatable {
    let displayLocation: NotchDisplayLocation
    let preferredDisplayUUID: String?
    let allowsAutomaticDisplaySwitching: Bool
}
