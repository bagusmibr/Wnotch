//
//  AudioOutputRouting.swift
//  Wnotch
//
//  Created by M on 4/8/26.
//

import Foundation
import CoreAudio

protocol AudioOutputRouting: AnyObject {
    func availableRoutes() -> [AudioOutputRoute]
    func currentRoute() -> AudioOutputRoute?
    @discardableResult func setCurrentRoute(_ id: AudioDeviceID) -> Bool
}
