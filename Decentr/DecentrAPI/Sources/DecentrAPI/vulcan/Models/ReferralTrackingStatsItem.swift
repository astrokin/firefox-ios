//
// ReferralTrackingStatsItem.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct ReferralTrackingStatsItem: Codable {

    public let confirmed: Int64?
    public let installed: Int64?
    public let registered: Int64?
    public let reward: Coin?

    public init(confirmed: Int64? = nil, installed: Int64? = nil, registered: Int64? = nil, reward: Coin? = nil) {
        self.confirmed = confirmed
        self.installed = installed
        self.registered = registered
        self.reward = reward
    }


}