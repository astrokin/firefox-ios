// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

//mute any telemetry

class TelemetryWrapper {
    
    let profile: Profile
    
    init(profile: Profile) {
        self.profile = profile
    }
    
    static func recordEvent(category: EventCategory, method: EventMethod, object: EventObject, value: EventValue? = nil, extras: [String: Any]? = nil) {
        
    }
    
    static func gleanRecordEvent(category: EventCategory, method: EventMethod, object: EventObject, value: EventValue? = nil, extras: [String: Any]? = nil) {
    }
}

// MARK: - Decentr Home Page
extension TelemetryWrapper {
    
    /// Bundle the extras dictionnary for the home page origin
    static func getOriginExtras(isZeroSearch: Bool) -> [String: String] {
        [:]
    }
}
