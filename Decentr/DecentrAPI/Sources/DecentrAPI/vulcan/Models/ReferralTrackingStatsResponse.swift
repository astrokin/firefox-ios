//
// ReferralTrackingStatsResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct ReferralTrackingStatsResponse: Codable {

    public var last30Days: ReferralTrackingStatsItem?
    public var total: ReferralTrackingStatsItem?

    public init(last30Days: ReferralTrackingStatsItem? = nil, total: ReferralTrackingStatsItem? = nil) {
        self.last30Days = last30Days
        self.total = total
    }


}
