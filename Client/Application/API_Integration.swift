// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import DecentrAPI
import Alamofire

final class API_Integration {
    
    static let shared: API_Integration = .init()
    
    
    init() {
        
    }
    
    func start() {
        makeRegister()
    }
    
    private func makeRegister() {
        let body: RegisterRequest = .init(address: "",
                                          email: "",
                                          recaptchaResponse: "",
                                          referralCode: "")
        DecentrAPI.VulcanAPI.register(body: body) { resp, err in
            print("\(resp)")
            print("\(err)")
        }
    }
}
