//
//  TravelPreference.swift
//  WanderGenie_Test
//
//  Created by Ahnaf Rahat on 22/5/25.
//

import Foundation

struct TravelPreference {
    var destination: String
    var startDate: Date
    var endDate: Date
    var numberOfTravelers: Int
    var preferredActivities: [String]
    var dailyBudget: Double
    var accommodationPreference: String
    var transportationPreference: String
    var specialNeeds: String

    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
