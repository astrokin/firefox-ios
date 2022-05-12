// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import DecentrAPI
import Dispatch
import CryptoSwift

protocol DecentrInfo {
    
    var isLoggedIn: Bool { get }

    func getAccount() -> DecentrAccount
    
    func savePlainSeedPhrase(_ seedPhrase: String)
    func getAESKey() -> String?
    func getAESIV() -> String?
    
    func saveEncryptedSeedPhrase(_ encryptedSeed: String?) //BIP39 Mnemonic
    func getSeedPhrase() -> String? //encrypted, use KeyStore then
    
    func savePassword(_ passwd: String?)
    func getPassword() -> String?
    
    /// - parameter completion: can be called multiple times
    func refreshAccountInfo(address: String?, _ completion: @escaping (Swift.Result<DecentrAccount, DecentrError>) -> ())
}

final class DC_Shared_Info: DecentrInfo {
    
    static let shared: DecentrInfo = DC_Shared_Info()
    
    private var account: DecentrAccount
    
    init() {
        self.account = .init()
    }
    
    var isLoggedIn: Bool {
        guard let acc = account.apiProfile else {
            return UserDefaults.standard.bool(forKey: "Decentr.Had.Login")
        }
        
        return acc.banned != true
    }
    
    func getAccount() -> DecentrAccount {
        account
    }
    
    func accountName() -> String {
        account.name
    }
    
    func saveEncryptedSeedPhrase(_ encryptedSeed: String?) {
        KeychainStore.shared.setString(encryptedSeed, forKey: "Decentr.Seed.Web.Enc")
    }
    
    func savePlainSeedPhrase(_ seedPhrase: String) {
        let _aesKey = String(NSUUID().uuidString.md5().prefix(16))
        let _aesIv = String(NSUUID().uuidString.md5().prefix(16))
        
        do {
            let aes = try AES(key: _aesKey, iv: _aesIv)
            let ciphertext = try aes.encrypt(Array(seedPhrase.utf8))
            let encryptedData = Data(ciphertext)
            UserDefaults.standard.set(encryptedData, forKey: "Decentr.Seed.Enc")
            saveAESKey(_aesKey)
            saveAESIV(_aesIv)
        } catch {
            print("error: \(error)")
        }
    }
    
    ///return encrypted seed phrase from local or remote encryption
    func getSeedPhrase() -> String? {
        KeychainStore.shared.string(forKey: "Decentr.Seed.Web.Enc")
    }
    
    func savePassword(_ passwd: String?) {
        KeychainStore.shared.setString(passwd, forKey: "Decentr.Password.Web")
    }
    
    func saveAESKey(_ key: String?) {
        KeychainStore.shared.setString(key, forKey: "Decentr.Seed.Local.Enc.Key")
    }
    
    func saveAESIV(_ iv: String?) {
        KeychainStore.shared.setString(iv, forKey: "Decentr.Seed.Local.Enc.IV")
    }
    
    func getAESKey() -> String? {
        KeychainStore.shared.string(forKey: "Decentr.Seed.Local.Enc.Key")
    }
    
    func getAESIV() -> String? {
        KeychainStore.shared.string(forKey: "Decentr.Seed.Local.Enc.IV")
    }
    
    func getPassword() -> String? {
        KeychainStore.shared.string(forKey: "Decentr.Password.Web")
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
                UserDefaults.standard.set(true, forKey: "Decentr.Had.Login")
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
    
    var name: String {
        let fi = (apiProfile?.firstName ?? "")
        let na = (apiProfile?.lastName ?? "")
        return fi + " " + na
    }
}

enum DecentrError: Swift.Error {
    case missingAddress
    case underlying(Error)
    case invalidData
}
