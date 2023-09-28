//
//  LocationAnnotation.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-09-08.
//

import Foundation
import MapKit

struct LocationAnnotation: Identifiable, Equatable, Hashable {
    let id = UUID()
    let fsq_id: String
    let title: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    let address: String
    let imageURL: String?
    let photos: [Photo]
    let tips: [Tips]
}

struct Photo:Hashable,Codable,Equatable, Identifiable
{
    let id:String
    let created_at: String
    let prefix: String
    let suffix: String
    let width: Int
    let height: Int
}

// MARK: - WelcomeElement
struct Tip: Codable, Equatable {
    let id, createdAt, text: String

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case text
    }
}

struct Tips: Hashable,Codable, Identifiable
{
    let id: String
    let created_at: String
    let text: String
}
