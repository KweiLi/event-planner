//
//  MapView.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-08-09.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject var locationManager = LocationManager()
    @State private var searchTerm:String = ""
    @State private var placeSelected:Bool = false

    
    var body: some View {
        
        NavigationStack{
            ZStack{
                Map(coordinateRegion: $locationManager.region, interactionModes: MapInteractionModes.all, showsUserLocation: true, annotationItems: locationManager.locationAnnotations,
                    annotationContent: { item in
                        MapAnnotation(coordinate: item.coordinate) {
                            Button(action: {
                                print(item.photos)
                                print(item.tips)
                                locationManager.currentLocation = item
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .frame(width: locationManager.currentLocation == item ? 20:15, height: locationManager.currentLocation == item ? 20:15, alignment: .center)
                                        .aspectRatio(contentMode: .fit)
                                        .accentColor(.white)
                                        .background(item == locationManager.currentLocation ? Color.blue : Color.green)
                                        .clipShape(Circle())
                                    
                                    Text(item.title)
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .lineLimit(1) // Ensures text remains on one line
                                        .truncationMode(.tail) // Truncates the text with an ellipsis if it's too long
                                        .fixedSize(horizontal: true, vertical: false) // Fixes the horizontal size to fit the content
                                }
                                .padding(10)
                                .background(item == locationManager.currentLocation ? Color.green.opacity(0.7) : Color.red.opacity(0.7))
                                .cornerRadius(25)
                            }
                        }
                    })
                    .ignoresSafeArea()
                    .onAppear {
                        locationManager.requestLocationPermission()
                    }
                
                VStack{
                    SearchBarView(text:$searchTerm)
                        .padding()
                    
                    Spacer()
                }
                
                VStack{
                    Spacer()
                    ZStack{
                        ForEach(locationManager.locationAnnotations) { location in
                            if location == locationManager.currentLocation{
                                PlaceCardView(location: location)
                                .shadow(color: Color.black.opacity(0.3), radius: 20)
                                .padding()
                            }
                        }
                    }.padding()
                }
            }
        }
        .environmentObject(locationManager)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(LocationManager())
    }
}

extension MapView{
    private var locationSearch: some View{
        VStack{
            Text("Hello World!")
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(.primary)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Image(systemName: "arrow.down")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                }
        }
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
}
