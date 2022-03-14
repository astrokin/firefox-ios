// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

protocol DecenterInfo {
    
    var account: DecenterAccount? { get }
    var seedPhrase: String? { get }
    var password: String? { get }
    
    func savePassword(_ passwd: String?)
}

final class DC_Shared_Info: DecenterInfo {
    
    static let shared: DecenterInfo = DC_Shared_Info()
    
    init() {
        if let seed = KeychainStore.shared.string(forKey: "Decentr.Key") {
            seedPhrase = seed
        }
        if let passwd = KeychainStore.shared.string(forKey: "Decentr.Password") {
            password = passwd
        }
    }
    
    private(set) var account: DecenterAccount?
    private(set) var seedPhrase: String? {
        didSet {
            if let value = seedPhrase {
//                KeychainStore.shared.setString(value, forKey: "Decentr.Key")
            }
        }
    }
    private(set) var password: String?
    func savePassword(_ passwd: String?) {
        if let value = passwd {
//            KeychainStore.shared.setString(value, forKey: "Decentr.Password")
        }
    }
}

struct DecenterAccount {
    
}
