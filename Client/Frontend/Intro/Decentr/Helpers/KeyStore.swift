// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import CryptoSwift
import WalletKit
import Account
import DecentrAPI
import SwiftyJSON
import secp256k1

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
        case failedToSign
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
        dispatchPrecondition(condition: .notOnQueue(.main))
        
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
        dispatchPrecondition(condition: .notOnQueue(.main))
        
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

extension RequestBuilder {
    
    func executeSignRequest(retryCount: Int = 2, _ completion: @escaping (Response<T>) -> (), failed: @escaping (Error?) -> () = { _ in }) {
        guard retryCount > 0 else {
            failed(nil)
            return
        }
        DispatchQueue.global(qos: .utility).async {
            do {
                let store = try KeyStore()
                let keys = try store.loadKeys()
                
                let bodyString = Self.getBodyAsJsonString(self.parameters) ?? ""
                let digest = bodyString + self.path //ex. Digest will be made from {"some":"file"}/v1/pdv
                let signature = try Self.sign(Data(hex: digest.sha256()), privateKey: Data(hex: keys.privateKey)).hexString.removingTrailingZeros()
                
                self.addHeader(name: "Signature", value: signature)
                self.addHeader(name: "Public-Key", value: keys.publicKey)
                
                //override parameters to keep bodyString consistent to avoid multiple codable encoding
                self.parameters = JSONDataEncoding.encodingParameters(jsonData: bodyString.data(using: .utf8))
                
                self.execute { response, error in
                    if let response = response {
                        completion(response)
                    } else {
                        self.executeSignRequest(retryCount: retryCount - 1, completion, failed: failed)
                    }
                }
                
            } catch {
                failed(KeyStore.Error.failedToSign)
            }
        }
    }
    
    static func getBodyAsJsonString(_ parameters: [String: Any]?) -> String? {
        guard let params = parameters, let data = params["jsonData"] as? Data else {
            return nil
        }
        let json = SwiftyJSON.JSON.init(data)
        let rawString = json.rawString(String.Encoding.utf8, options: .init(rawValue: 0))?.replacingOccurrences(of: "\\", with: "")
        return rawString
    }
    
    private static func sign(_ hash: Data, privateKey: Data) throws -> Data {
        let encrypter = EllipticCurveEncrypterSecp256k1()
        guard var signatureInInternalFormat = encrypter.sign(hash: hash, privateKey: privateKey) else {
            throw KeyStore.Error.failedToSign
        }
        return encrypter.export(signature: &signatureInInternalFormat)
    }
}

fileprivate extension String {
    
    func removingTrailingZeros() -> String {
        if hasSuffix("00") || hasSuffix("01") {
            return String(dropLast(2))
        }
        return self
    }
}

//MARK: - EllipticCurveEncrypterSecp256k1

fileprivate enum SecpResult {
    case success
    case failure
    
    init(_ result:Int32) {
        switch result {
        case 1:
            self = .success
        default:
            self = .failure
        }
    }
}

fileprivate class EllipticCurveEncrypterSecp256k1 {
    // holds internal state of the c library
    private let context: OpaquePointer
    
    fileprivate init() {
        context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!
    }
    
    deinit {
        secp256k1_context_destroy(context)
    }
    
    /// Recovers public key from the PrivateKey. Use import(signature:) to convert signature from bytes.
    ///
    /// - Parameters:
    ///   - privateKey: private key bytes
    /// - Returns: public key structure
    fileprivate func createPublicKey(privateKey: Data) -> secp256k1_pubkey {
        let privateKey = privateKey.bytes
        var publickKey = secp256k1_pubkey()
        _ = SecpResult(secp256k1_ec_pubkey_create(context, &publickKey, privateKey))
        return publickKey
    }
    
    /// Signs the hash with the private key. Produces signature data structure that can be exported with
    /// export(signature:) method.
    ///
    /// - Parameters:
    ///   - hash: 32-byte (256-bit) hash of the message
    ///   - privateKey: 32-byte private key
    /// - Returns: signature data structure if signing succeeded, otherwise nil.
    fileprivate func sign(hash: Data, privateKey: Data) -> secp256k1_ecdsa_recoverable_signature? {
        precondition(hash.count == 32, "Hash must be 32 bytes size")
        var signature = secp256k1_ecdsa_recoverable_signature()
        privateKey.withUnsafeBytes { privateKey -> Void in
            guard let privateKeyPtr = privateKey.bindMemory(to: UInt8.self).baseAddress else { return }
            hash.withUnsafeBytes { hash -> Void in
                guard let hashPtr = hash.bindMemory(to: UInt8.self).baseAddress else { return }
                secp256k1_ecdsa_sign_recoverable(context, &signature, hashPtr, privateKeyPtr, nil, nil)
            }
        }
        return signature
    }
    
    /// Converts signature data structure to 65 bytes.
    ///
    /// - Parameter signature: signature data structure
    /// - Returns: 65 byte exported signature data.
    fileprivate func export(signature: inout secp256k1_ecdsa_recoverable_signature) -> Data {
        var output = Data(count: 65)
        var recId = 0 as Int32
        _ = output.withUnsafeMutableBytes { output in
            guard let p = output.bindMemory(to: UInt8.self).baseAddress else { return }
            secp256k1_ecdsa_recoverable_signature_serialize_compact(context, p, &recId, &signature)
        }
        
        output[64] = UInt8(recId)
        return output
    }
    
    /// Converts serialized signature into library's signature format. Use it to supply signature to
    /// the publicKey(signature:hash:) method.
    ///
    /// - Parameter signature: serialized 65-byte signature
    /// - Returns: signature structure
    fileprivate func `import`(signature: Data) -> secp256k1_ecdsa_recoverable_signature {
        precondition(signature.count == 65, "Signature must be 65 byte size")
        var sig = secp256k1_ecdsa_recoverable_signature()
        let recId = Int32(signature[64])
        signature.withUnsafeBytes { input -> Void in
            guard let p = input.bindMemory(to: UInt8.self).baseAddress else { return }
            secp256k1_ecdsa_recoverable_signature_parse_compact(context, &sig, p, recId)
        }
        return sig
    }
    
    /// Recovers public key from the signature and the hash. Use import(signature:) to convert signature from bytes.
    /// Use export(publicKey:compressed) to convert recovered public key into bytes.
    ///
    /// - Parameters:
    ///   - signature: signature structure
    ///   - hash: 32-byte (256-bit) hash of a message
    /// - Returns: public key structure or nil, if signature invalid
    fileprivate func publicKey(signature: inout secp256k1_ecdsa_recoverable_signature, hash: Data) -> secp256k1_pubkey? {
        precondition(hash.count == 32, "Hash must be 32 bytes size")
        let hash = hash.bytes
        var outPubKey = secp256k1_pubkey()
        let status = SecpResult(secp256k1_ecdsa_recover(context, &outPubKey, &signature, hash))
        return status == .success ? outPubKey : nil
    }
    
    /// Converts public key from library's data structure to bytes
    ///
    /// - Parameters:
    ///   - publicKey: public key structure to convert.
    ///   - compressed: whether public key should be compressed.
    /// - Returns: If compression enabled, public key is 33 bytes size, otherwise it is 65 bytes.
    fileprivate func export(publicKey: inout secp256k1_pubkey, compressed: Bool) -> Data {
        var output = Data(count: compressed ? 33 : 65)
        var outputLen: Int = output.count
        let compressedFlags = compressed ? UInt32(SECP256K1_EC_COMPRESSED) : UInt32(SECP256K1_EC_UNCOMPRESSED)
        output.withUnsafeMutableBytes { pointer -> Void in
            guard let p = pointer.bindMemory(to: UInt8.self).baseAddress else { return }
            secp256k1_ec_pubkey_serialize(context, p, &outputLen, &publicKey, compressedFlags)
        }
        return output
    }
}
