//
//  Event.swift
//  event-planner
//
//  Created by Kun Chen on 2023-09-28.
//

import Foundation
struct Event: Identifiable, Codable {
    let id = UUID()
    let fsq_id: String
    let place_name: String
    let place_addr: String
    let eventTime: String
    let eventDate: String
    
    enum CodingKeys: String, CodingKey {
        case fsq_id, place_name, place_addr, eventTime, eventDate
    }
}
