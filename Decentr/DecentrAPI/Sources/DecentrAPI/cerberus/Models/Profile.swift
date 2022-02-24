//
// Profile.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Profile: Codable {

    public enum ModelType: String, Codable { 
        case advertiserid = "advertiserId"
        case cookie = "cookie"
        case profile = "profile"
        case searchhistory = "searchHistory"
        case location = "location"
    }
    public var type: ModelType?
    public var avatar: String?
    public var bio: String?
    public var birthday: Date?
    public var emails: [String]?
    public var firstName: String?
    public var gender: Gender?
    public var lastName: String?

    public init(type: ModelType? = nil, avatar: String? = nil, bio: String? = nil, birthday: Date? = nil, emails: [String]? = nil, firstName: String? = nil, gender: Gender? = nil, lastName: String? = nil) {
        self.type = type
        self.avatar = avatar
        self.bio = bio
        self.birthday = birthday
        self.emails = emails
        self.firstName = firstName
        self.gender = gender
        self.lastName = lastName
    }


}
