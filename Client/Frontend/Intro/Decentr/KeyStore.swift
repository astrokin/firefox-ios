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
    }
    
    let seedPhrase: String //base64 encrypted seed phrase in case of encrypted init
    let password: String?
    private let isEncryptedSeed: Bool
    
    init(encryptedSeed: String, password: String?) {
        self.seedPhrase = encryptedSeed
        self.password = password ?? DC_Shared_Info.shared.getPassword()
        self.isEncryptedSeed = true
    }
    
    init(seedPhrase: String, password: String?) {
        self.seedPhrase = seedPhrase
        self.password = password ?? DC_Shared_Info.shared.getPassword()
        self.isEncryptedSeed = false
    }
    
    init(info: DecentrInfo = DC_Shared_Info.shared) throws {
        guard let seed = info.getSeedPhrase() else {
            throw Error.missingEncryptedSeed
        }
        self.init(encryptedSeed: seed, password: info.getPassword())
    }
    
    func loadKeys() throws -> Keys {
        guard let password = password else {
            throw Error.missingPassword
        }
        let seed: String
        if isEncryptedSeed {
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
