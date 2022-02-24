//
// V1.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct V1: Codable {

    public var version: String?
    public var pdv: [DataV1]?

    public init(version: String? = nil, pdv: [DataV1]? = nil) {
        self.version = version
        self.pdv = pdv
    }


}
