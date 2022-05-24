//
// PDV.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct PDV: Codable {

    public let version: String?

    public init(version: String? = nil) {
        self.version = version
    }
}

public struct PDVPrifileRequest: Codable {
    
    public let version: String?
    public let pdv: [PDVProfile]?

    public init(version: String? = nil, pdv: [PDVProfile]? = nil) {
        self.version = version
        self.pdv = pdv
    }
}

public struct PDVDataRequest: Codable {
    
    public let version: String?
    public let pdv: [PDVItem]?

    public init(version: String? = nil, pdv: [PDVItem]? = nil) {
        self.version = version
        self.pdv = pdv
    }
}

public struct PDVItem: Codable, Equatable {
    
    public static let dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    public let type: String
    public let domain: String
    public let engine: String
    public let query: String
    public let timestamp: String // dateFormat
    
    public init(type: String = "searchHistory", domain: String, engine: String, query: String, timestamp: String) {
        self.type = type
        self.domain = domain
        self.engine = engine
        self.query = query
        self.timestamp = timestamp
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.domain == rhs.domain &&
        lhs.engine == rhs.engine &&
        lhs.query == rhs.query
    }
}

public struct PDVProfile: Codable {
    
    public let type: String
    public let avatar: String?
    public let bio: String?
    public let birthday: String? //object (Date in ISO-8601 format (yyyy-mm-dd).)
    public let emails: [String]?
    public let gender: String? //string (Gender can be male or female.)
    public let firstName: String?
    public let lastName: String?
    
    public init(type: String = "profile", avatar: String? = nil, bio: String? = nil, birthday: String? = nil, emails: [String]? = nil, gender: String? = nil, firstName: String? = nil, lastName: String? = nil) {
        self.type = type
        self.avatar = avatar
        self.bio = bio
        self.birthday = birthday
        self.emails = emails
        self.gender = gender
        self.firstName = firstName
        self.lastName = lastName
    }
}

