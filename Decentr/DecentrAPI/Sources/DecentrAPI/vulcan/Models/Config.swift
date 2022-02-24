//
// Config.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct Config: Codable {

    public var receiverReward: ModelInt?
    public var senderBonus: [Bonus]?
    public var senderRewardLevels: [RewardLevel]?
    public var thresholdDays: Int64?
    public var thresholdPDV: Dec?

    public init(receiverReward: ModelInt? = nil, senderBonus: [Bonus]? = nil, senderRewardLevels: [RewardLevel]? = nil, thresholdDays: Int64? = nil, thresholdPDV: Dec? = nil) {
        self.receiverReward = receiverReward
        self.senderBonus = senderBonus
        self.senderRewardLevels = senderRewardLevels
        self.thresholdDays = thresholdDays
        self.thresholdPDV = thresholdPDV
    }


}
