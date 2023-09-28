//
//  APIManager.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-08-08.
//

import Foundation
import SwiftUI

class APIManager: ObservableObject{
 
    // MARK: Calling Places Search API
    
    func fetchPlaces(keyword: String, lat: Double, long: Double) async throws -> Initial {
        let headers = [
            "Accept": "application/json",
            "Authorization": "fsq33dI/vsae94NERY8Uso2TBYKLDE5eWfck4O6we2A4idM="
        ]

        // Safely construct the URL
        guard let url = URL(string: "https://api.foursquare.com/v3/places/search?query=\(keyword)&ll=\(lat)%2C\(long)&limit=20") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let jsonData = try JSONDecoder().decode(Initial.self, from: data)
        return jsonData
    }


    
    //MARK: Calling Places Images API
    func callImagesApi(fsq_id: String) async throws -> [Photo] {
        let headers = [
            "Accept": "application/json",
            "Authorization": "fsq33dI/vsae94NERY8Uso2TBYKLDE5eWfck4O6we2A4idM="
        ]

        let url = URL(string: "https://api.foursquare.com/v3/places/\(fsq_id)/photos")!
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.allHTTPHeaderFields = headers

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Photo].self, from: data)
    }

    //MARK: Calling Places Tips API
    func callTipsApi(fsq_id: String) async throws -> [Tips] {
        let headers = [
            "Accept": "application/json",
            "Authorization": "fsq33dI/vsae94NERY8Uso2TBYKLDE5eWfck4O6we2A4idM="
        ]

        let url = URL(string: "https://api.foursquare.com/v3/places/\(fsq_id)/tips?limit=20&sort=NEWEST")!
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.allHTTPHeaderFields = headers

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Tips].self, from: data)
    }

    //MARK: Calling Places Nearby API
    func callNearbyPlacesApi(lat: Double, long: Double) async throws -> Initial {
        let headers = [
            "Accept": "application/json",
            "Authorization": "fsq33dI/vsae94NERY8Uso2TBYKLDE5eWfck4O6we2A4idM="
        ]

        let url = URL(string: "https://api.foursquare.com/v3/places/nearby?ll=\(lat)%2C\(long)&limit=50")!
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.allHTTPHeaderFields = headers

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(Initial.self, from: data)
    }


}
