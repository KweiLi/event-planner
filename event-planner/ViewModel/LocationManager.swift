//
//  LocationManager.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-08-11.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var location: CLLocation?
    
    @Published var locationAnnotations: [LocationAnnotation] = []
    @Published var region = MKCoordinateRegion()
    @Published var currentLocation: LocationAnnotation? {
        didSet {
            DispatchQueue.main.async {
                if let currentLocation = self.currentLocation {
                    self.spanToAnnotation(annotation: currentLocation)
                }
            }
        }
    }

    private var apiManager = APIManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    
    func getLocation(searchKey: String, lat: Double, long: Double) {
        fetchLocation(searchKey: searchKey, lat: lat, long: long) { (annotations) in
            DispatchQueue.main.async {
                self.locationAnnotations = annotations
                if self.locationAnnotations.count > 0 {
                    self.currentLocation = self.locationAnnotations[0]
                }
            }
        }
    }
    
    func fetchLocation(searchKey: String, lat: Double, long: Double, completion: @escaping ([LocationAnnotation]) -> Void) {
        Task {
            var localAnnotations: [LocationAnnotation] = []
            do {
                let listOf = try await apiManager.fetchPlaces(keyword: searchKey, lat: lat, long: long)

                for result in listOf.results {
                    let fsqID = result.fsq_id
                    let name = result.name
                    let address = result.location.address ?? ""
                    let iconPrefix = result.categories.first?.icon.prefix
                    let iconSuffix = result.categories.first?.icon.suffix
                    let iconURL = (iconPrefix ?? "") + "bg_100" + (iconSuffix ?? "")
                    let lat = result.geocodes.main.latitude
                    let lon = result.geocodes.main.longitude
                    
                    if let fsqID = fsqID, let lat = lat, let lon = lon {
                        let images = try? await apiManager.callImagesApi(fsq_id: fsqID)
                        let tips = try? await apiManager.callTipsApi(fsq_id: fsqID)
                        let locationAnnotation =  LocationAnnotation(fsq_id: fsqID, title: name, latitude: lat, longitude: lon, address: address, imageURL: iconURL, photos: images ?? [], tips: tips ?? [])
                        localAnnotations.append(locationAnnotation)
                    } else {
                        print("Discarding record due to missing data.")
                    }
                }
                
                completion(localAnnotations)
            } catch {
                print("Error Processing JSON Data \(error)")
            }
        }
    }

    func updateMapregion(location:CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        }
    }
    
    func spanToAnnotation(annotation: LocationAnnotation) {
        self.region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    }

    func spanToNextLocationAnnotation(location: LocationAnnotation){
        DispatchQueue.main.async {
            if let currentLocationIndex = self.locationAnnotations.firstIndex(where: {$0 == location}) {
                let nextIndex = currentLocationIndex + 1
                self.currentLocation = self.locationAnnotations[nextIndex%self.locationAnnotations.count]
            }
        }
    }
}
