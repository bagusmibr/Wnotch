//
//  LyricLine.swift
//  Wnotch
//
//  Created by M on 5/13/26.
//

import Foundation

struct LyricLine: Identifiable, Equatable, Sendable {
    let id: Int
    let startTime: TimeInterval?
    let text: String
}
