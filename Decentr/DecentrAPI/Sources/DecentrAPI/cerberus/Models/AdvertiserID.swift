//
// AdvertiserId.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct AdvertiserId: Codable {

    public enum ModelType: String, Codable { 
        case advertiserid = "advertiserId"
        case cookie = "cookie"
        case profile = "profile"
        case searchhistory = "searchHistory"
        case location = "location"
    }
    public var type: ModelType?
    public var advertiser: String?
    public var name: String?
    public var value: String?

    public init(type: ModelType? = nil, advertiser: String? = nil, name: String? = nil, value: String? = nil) {
        self.type = type
        self.advertiser = advertiser
        self.name = name
        self.value = value
    }


}
