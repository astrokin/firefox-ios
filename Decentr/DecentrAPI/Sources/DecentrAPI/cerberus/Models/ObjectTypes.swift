//
// ObjectTypes.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct ObjectTypes: Codable {

    public let advertiserId: Int?
    public let cookie: Int?
    public let location: Int?
    public let profile: Int?
    public let searchHistory: Int?

    public init(advertiserId: Int? = nil, cookie: Int? = nil, location: Int? = nil, profile: Int? = nil, searchHistory: Int? = nil) {
        self.advertiserId = advertiserId
        self.cookie = cookie
        self.location = location
        self.profile = profile
        self.searchHistory = searchHistory
    }


}
