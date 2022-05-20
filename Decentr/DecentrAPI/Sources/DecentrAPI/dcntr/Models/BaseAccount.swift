//
//  BaseAccount.swift
//  
//
//  Created by Alexey Strokin on 5/7/22.
//

import Foundation

//{
//    "account": {
//        "@type": "/cosmos.auth.v1beta1.BaseAccount",
//        "address": "decentr17wr6f2fwdl05se4w5k5f20wql7lncn9ua7lm84",
//        "pub_key": {
//            "@type": "/cosmos.crypto.secp256k1.PubKey",
//            "key": "Al92taAeA4YtHRuZP5XlWQVJW15cEyn50Lu6oO2bitZm"
//        },
//        "account_number": "21383",
//        "sequence": "1"
//    }
//}

public struct BaseAccount: Codable {
    public let  account: BaseAccountInfo?
}

public struct BaseAccountInfo: Codable {
    public let  address: String?
    public let  pub_key: BaseAccountInfoKey?
    public let  account_number: String?
    public let  sequence: String?
}

public struct BaseAccountInfoKey: Codable {
    let key: String?
}

//{
//    "balance": {
//        "dec": "1.003215000000000000"
//    }
//}

public struct BalanceDEC: Codable {
    public let  balance: DEC_Balance?
}

public struct DEC_Balance: Codable {
    public let  dec: String?
}

//{
//    "balances": [
//        {
//            "denom": "udec",
//            "amount": "4803661"
//        }
//    ],
//    "pagination": {
//        "next_key": null,
//        "total": "1"
//    }
//}

public struct BalancePDV: Codable {
    public let  balances: [PDV_Balance]?
}

public struct PDV_Balance: Codable {
    public let  denom: String?
    public let  amount: String?
}
