//
//  OnboardingSteps.swift
//  Wnotch
//
//  Created by M on 4/13/26.
//

import SwiftUI

enum OnboardingSteps: String, Equatable, CaseIterable {
    case first
    case second
    
    static let stackID = NotchContentRegistry.Onboarding.stackID
    
    var liveActivityID: String {
        NotchContentRegistry.Onboarding.id(forStep: rawValue)
    }
    
    static func contains(id: String?) -> Bool {
        guard let id else { return false }
        return allCases.contains(where: { $0.liveActivityID == id })
    }
    
    func notchSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        switch self {
        case .first:
            .init(width: baseWidth + 70, height: baseHeight + 110)
        case .second:
            .init(width: baseWidth + 160, height: baseHeight + 140)
        }
    }
    
    func dynamicIslandSize(baseWidth: CGFloat, baseHeight: CGFloat) -> CGSize {
        switch self {
        case .first:
            .init(width: baseWidth + 180, height: baseHeight + 100)
        case .second:
            .init(width: baseWidth + 250, height: baseHeight + 130)
        }
    }
    
    #if DEBUG
    static let debugStackID = NotchContentRegistry.Onboarding.debugStackID
    
    var debugLiveActivityID: String {
        NotchContentRegistry.Onboarding.debugID(forStep: rawValue)
    }
    
    static func containsDebug(id: String?) -> Bool {
        guard let id else { return false }
        return allCases.contains(where: { $0.debugLiveActivityID == id })
    }
    #endif
}
