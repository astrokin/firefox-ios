// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import DecentrAPI
import Dispatch

protocol DecentrInfo {
    
    var account: DecentrAccount { get }
    
    func saveEencryptedSeedPhrase(_ encryptedSeed: String?) //BIP39 Mnemonic
    func getSeedPhrase() -> String? //encrypted, use KeyStore then
    
    func savePassword(_ passwd: String?)
    func getPassword() -> String?
    
    /// - parameter completion: can be called multiple times
    func refreshAccountInfo(address: String?, _ completion: @escaping (Swift.Result<DecentrAccount, DecentrError>) -> ())
}

final class DC_Shared_Info: DecentrInfo {
    
    static let shared: DecentrInfo = DC_Shared_Info()
    
    var account: DecentrAccount
    
    init() {
        self.account = .init()
    }
    
    func saveEencryptedSeedPhrase(_ encryptedSeed: String?) {
        KeychainStore.shared.setString(encryptedSeed, forKey: "Decentr.Seed")
    }
    
    func getSeedPhrase() -> String? {
        KeychainStore.shared.string(forKey: "Decentr.Seed")
    }
    
    func savePassword(_ passwd: String?) {
        KeychainStore.shared.setString(passwd, forKey: "Decentr.Password")
    }
    
    func getPassword() -> String? {
        KeychainStore.shared.string(forKey: "Decentr.Password")
    }
    
    /// - parameter completion: can be called multiple times
    func refreshAccountInfo(address: String?, _ completion: @escaping (Swift.Result<DecentrAccount, DecentrError>) -> ()) {
        guard let address = address ?? (try? KeyStore(info: self).loadKeys().address) else {
            completion(.failure(.missingAddress))
            return
        }

        if account.isValid {
            completion(.success(account))
        }
        DcntrAPI.ProfilesAPI.getCheckAddress(address: address) { data, error in
            if let error = error {
                completion(.failure(.underlying(error)))
                return
            }
            if data == nil {
                completion(.failure(.invalidData))
                return
            }
            
            let group = DispatchGroup()
            
            group.enter()
            DcntrAPI.ProfilesAPI.getCheckBalanceDEC(address: address) { data, error in
                if let data = data {
                    self.account.decBalance = data
                }
                group.leave()
            }
            
            group.enter()
            DcntrAPI.ProfilesAPI.getCheckBalancePDV(address: address) { data, error in
                if let data = data {
                    self.account.pdvBalance = data
                }
                group.leave()
            }
            
            group.enter()
            DcntrAPI.ProfilesAPI.getCheckAddress(address: address) { data, error in
                if let data = data {
                    self.account.baseAccount = data
                }
                group.leave()
            }
            
            group.enter()
            CerberusAPI.ProfileAPI.getProfiles(address: address) { data, error in
                if let profile = data?.first {
                    self.account.apiProfile = profile
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                completion(.success(self.account))
            }
        }
    }
}

struct DecentrAccount {
    fileprivate(set) var decBalance: BalanceDEC?
    fileprivate(set) var pdvBalance: BalancePDV?
    fileprivate(set) var baseAccount: BaseAccount?
    fileprivate(set) var apiProfile: APIProfile?
    
    fileprivate init() {
    }
    
    var isValid: Bool {
        decBalance != nil &&
        pdvBalance != nil &&
        baseAccount != nil &&
        apiProfile != nil
    }
}

enum DecentrError: Swift.Error {
    case missingAddress
    case underlying(Error)
    case invalidData
}
