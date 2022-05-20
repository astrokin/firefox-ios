//
// Cookie.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Cookie: Codable {

    public enum ModelType: String, Codable { 
        case advertiserid = "advertiserId"
        case cookie = "cookie"
        case profile = "profile"
        case searchhistory = "searchHistory"
        case location = "location"
    }
    public let type: ModelType?
    public let domain: String?
    public let expirationDate: Int?
    public let hostOnly: Bool?
    public let name: String?
    public let path: String?
    public let sameSite: String?
    public let secure: Bool?
    public let source: Source?
    public let timestamp: Date?
    public let value: String?

    public init(type: ModelType? = nil, domain: String? = nil, expirationDate: Int? = nil, hostOnly: Bool? = nil, name: String? = nil, path: String? = nil, sameSite: String? = nil, secure: Bool? = nil, source: Source? = nil, timestamp: Date? = nil, value: String? = nil) {
        self.type = type
        self.domain = domain
        self.expirationDate = expirationDate
        self.hostOnly = hostOnly
        self.name = name
        self.path = path
        self.sameSite = sameSite
        self.secure = secure
        self.source = source
        self.timestamp = timestamp
        self.value = value
    }


}
