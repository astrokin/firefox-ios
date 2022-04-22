// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

public class EVP_KDF_Util {
    
    public class func generate_evp_kdf_aes256cbc_key_iv(pass: String, saltData: [UInt8]) throws -> (String, String) {
        
        let passData = [UInt8](pass.data(using: .utf8)!)
        
        let keySize: Int = 32
        let keyPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: keySize)
        keyPointer.initialize(repeating: 0, count: keySize)
        
        let ivSize: Int = 16
        let ivPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: ivSize)
        ivPointer.initialize(repeating: 0, count: ivSize)
    
        let err = gen_evp_kdf_aes256cbc(passData, saltData, keyPointer, ivPointer)
        
        if err != ECE_OK {
            throw PushCryptoError.decryptionError(errCode: err)
        }
        
        let key = Data(bytes: keyPointer, count: keySize).map({ String(format: "%02hhx", $0) }).joined()
        let iv = Data(bytes: ivPointer, count: ivSize).map({ String(format: "%02hhx", $0) }).joined()
        
        return (key, iv)
    }
}
