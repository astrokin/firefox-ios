// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import CryptoSwift
import WalletKit
import Account

struct KeyStore {
    
    struct Keys {
        let privateKey: String
        let publicKey: String
        let address: String
    }
    
    enum Error: Swift.Error {
        case missingPassword
        case missingEncryptedSeed
        case missingEncryptedSeedData
        case invalidEncryptedSeedData
    }
    
    let seedPhrase: String //base64 encrypted seed phrase in case of encrypted init
    let password: String?
    private let isEncryptedSeed: Bool
    
    init(encryptedSeed: String, password: String) {
        self.seedPhrase = encryptedSeed
        self.password = password
        self.isEncryptedSeed = true
    }
    
    init(seedPhrase: String) {
        self.seedPhrase = seedPhrase
        self.password = nil
        self.isEncryptedSeed = false
    }
    
    init(info: DecentrInfo = DC_Shared_Info.shared) throws {
        if let seed = info.getSeedPhrase(), let password = info.getPassword() {
            self.init(encryptedSeed: seed, password: password)
        } else if let encryptedData = UserDefaults.standard.value(forKey: "Decentr.Seed.Enc") as? Data,
                  let aesKey = info.getAESKey(),
                    let aesIV = info.getAESIV() {
            let aes = try AES(key: aesKey, iv: aesIV)
            let decryptedBytes = try aes.decrypt(encryptedData.bytes)
            let decryptedData = Data(decryptedBytes)
            if let seed = String(data: decryptedData, encoding: .utf8) {
                self.init(seedPhrase: seed)
            } else {
                throw Error.invalidEncryptedSeedData
            }
        } else {
            throw Error.missingEncryptedSeedData
        }
    }
    
    func loadKeys() throws -> Keys {
        let seed: String
        if isEncryptedSeed {
            guard let password = password else {
                throw Error.missingPassword
            }
            seed = try Self.decrypt(seedPhrase, passwordUtf8: password)
        } else {
            seed = seedPhrase
        }
        
        let mnemonic = try Mnemonic(seedPhrase: seed)
        let wallet = try mnemonic.createWallet()
        let coinType = AnyCoinType.ATOM
        let account = try wallet.account(coinType: coinType, atIndex: 0)
        
        let privateKey = account.privateKey.key.hexString.removeLeadingZero()
        let pubKey = try account.privateKey.publicKey()
        let address = try coinType.address(for: pubKey, addressPrefix: "decentr")
        let publicKey = pubKey.key.hexString
        
        return Keys(privateKey: privateKey,
                    publicKey: publicKey,
                    address: address)
    }
    
    private static func decrypt(_ base64String: String, passwordUtf8: String) throws -> String {
        let encrypted = Data(base64Encoded: base64String)!
        let salt = [UInt8](encrypted[8 ..< 16])
        let evp = try EVP_KDF_Util.generate_evp_kdf_aes256cbc_key_iv(pass: passwordUtf8, saltData: salt) // key + iv
        let aes = try AES(key: Array<UInt8>.init(hex: evp.0),
                          blockMode: CBC(iv: Array<UInt8>.init(hex: evp.1)),
                          padding: .pkcs7)
        let data = [UInt8](encrypted[16 ..< encrypted.count])
        let decrypted = try aes.decrypt(data)
        
        guard let decryptedStr = String(bytes: decrypted, encoding: .utf8) else {
            throw AES.Error.invalidData
        }
        return decryptedStr
    }
}

