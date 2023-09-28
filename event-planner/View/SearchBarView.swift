//
//  SearchBarView.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-08-09.
//

import SwiftUI
import TagLayoutView
import MapKit

struct SearchBarView: View {
    @Binding var text: String
    @State private var isEditing = false
    @FocusState private var nameIsFocused: Bool

    @EnvironmentObject var locationManager:LocationManager
    
    let gridItems = [GridItem(),GridItem()]
    
    var tags:[String] = ["restaurants", "dining", "park", "event", "gym", "trail", "arts", "cinema"]
    
    var body: some View {
        
        VStack (spacing: 10){
            Text("Explore the area")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(
                    .system(
                        .largeTitle,
                        design: .rounded
                    )
                    .weight(.bold)
                )

            HStack {
                TextField("Search ...", text: $text)
                    .focused($nameIsFocused)
                    .frame(height: 30)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                     
                            if isEditing {
                                Button(action: {
                                    self.text = ""
                                    isEditing = false
                                    nameIsFocused = false
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        locationManager.currentLocation = nil
                        self.isEditing = true
                    }

                Button(action: {
                
                    let start = DispatchTime.now()

                    locationManager.locationAnnotations = []
                    
                    if locationManager.locationStatus == .authorizedWhenInUse || locationManager.locationStatus == .authorizedAlways {
                        if let location = locationManager.location {
                            locationManager.region.center = location.coordinate
                            locationManager.getLocation(searchKey: self.text, lat: locationManager.region.center.latitude, long: locationManager.region.center.longitude)
                        }
                    } else {
                        locationManager.requestLocationPermission()
                    }
                    
                    let end = DispatchTime.now()
                    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
                    let timeInterval = Double(nanoTime) / 1_000_000_000
                    print("Time to evaluate problem: \(timeInterval) seconds")

                    
                    self.isEditing = false
                    self.text = ""
                    self.nameIsFocused = false

                }) {
                    Image(systemName: "chevron.right.square.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.purple)
                    }
            }
            
            if isEditing{
                TagListView(tags: tags, searchKey: $text)
            }
        }
    }
}
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LocationManager())
    }
}

