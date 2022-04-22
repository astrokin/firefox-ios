// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import CryptoSwift
import Account

final class DC_SignIn_Flow {
    
    enum Step {
        case scanQR
        case enterSeed(base64Enc: String?)
        case enterPassword
    }
    
    weak var navigationController: UINavigationController?
    var completion: (() -> ())?
    
    var decryptedSeed: String?
    var encryptedSeedFromQR: String?
    var password: String?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func startSignIn() {
        goToStep(.scanQR)
    }
    
    private func goToStep(_ step: Step) {
        switch step {
        case .scanQR:
            let vc = DC_Login()
            vc.qrCodeScanner.didScanQRCodeWithURL = { url in
            }
            vc.qrCodeScanner.didScanQRCodeWithText = { [weak self] text in
                self?.goToStep(.enterSeed(base64Enc: text))
            }
            vc.completion = { [weak self] in
                self?.goToStep(.enterSeed(base64Enc: nil))
            }
            navigationController?.pushViewController(vc, animated: true)
        case let .enterSeed(base64EncryptedSeed):
            let vc = DC_Enter_Seed()
            vc.seedPhrase = nil
            if let seed = base64EncryptedSeed {
                var components = URLComponents(string: seed)
                components?.scheme = "decentr"
                if let enc = components?.queryItems?.first(where: { $0.name == "encryptedSeed" })?.value {
                    self.encryptedSeedFromQR = enc
                    do {
                        print("AES encrypted: \(enc)")
                        let testData: String = "" //password for base64 seed encryption
                        let decryptedSeed = try Self.decrypt(enc, passwordUtf8: testData)
                        vc.seedPhrase = decryptedSeed
                    } catch {
                        print("AES decrypted: error \(error)")
                    }
                }
            }
            vc.completion = { [weak self] in
                self?.goToStep(.enterPassword)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .enterPassword:
            let vc = DC_Password(didSavePassword: { [weak self] in
                self?.completion?()
            })
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

private extension DC_SignIn_Flow {
    
    static func decrypt(_ base64String: String, passwordUtf8: String) throws -> String {
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
