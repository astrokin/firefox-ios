//
// RegisterStats.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct RegisterStats: Codable {

    public let stats: [VulcanAPI.StatsItem]?
    public let total: Int64?

    public init(stats: [VulcanAPI.StatsItem]? = nil, total: Int64? = nil) {
        self.stats = stats
        self.total = total
    }


}
