//
//  App.swift
//  ImageFlowMac
//
//  Created by Daniel Fortes on 27/04/26.
//

import AppKit
import AppMacOS

@main
extension EntryPoint {
    public static func main() {
        #if IMAGEFLOW_TRIAL_BUILD
        Self.run(trialBuild: true)
        #else
        Self.run(trialBuild: false)
        #endif
    }
}
