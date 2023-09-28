//
//  LocationPreviewView.swift
//  AppPlanner
//
//  Created by Kun Chen on 2023-08-14.
//

import SwiftUI

struct PlaceCardView: View {
    
    var location: LocationAnnotation
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var selectedImage: Photo?
    @State private var selectedIndex: Int = 0

    
    @State private var showDetails: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    @State private var tabViewHeight: CGFloat = 180

    var body: some View {
        VStack {
            VStack {
                placeCard
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                withAnimation {
                                    if dragOffset > 50 {
                                        showDetails = false
                                    } else if dragOffset < -50 {
                                        showDetails = true
                                    }
                                }
                            }
                    )
                
                if showDetails {
                    if location.photos.count > 0 {
                        locationPhotos
                    }
                    
                    if location.tips.count > 0 {
                        locationTips
                    }
                }
            }
        }
    }
}


extension PlaceCardView {
    
    private var placeCard: some View{
        HStack(alignment: .bottom, spacing: 10) {
            // Your main content
            VStack(alignment: .leading, spacing: 16){
                imageSection
                titleSection
            }
            
            VStack(spacing: 8) {
                detailsButton
                nextButton
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .cornerRadius(10)
    }
    
    private var imageSection: some View{
        ZStack {
            if let imgURL = location.imageURL {
                AsyncImage(url: URL(string: imgURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 80)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 80)
                    .cornerRadius(10)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var titleSection: some View{
        VStack (alignment: .leading, spacing: 5) {
            Text(location.title)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(location.address)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var detailsButton: some View {
        NavigationLink {
            EventSchedulerView(locationAnnotation: location)
        } label: {
            Text("Schedule")
                .frame(width: 90, height: 35)
                .padding(.horizontal)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    private var nextButton: some View{
        Button{
            if let currentLocation = locationManager.currentLocation {
                locationManager.spanToNextLocationAnnotation(location: currentLocation)
            }
        } label: {
            Text("Next")
                .font(.headline)
                .frame(width: 90, height: 35)
        }
        .buttonStyle(.bordered)
    }
    
    func formatDate(from string: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = inputFormatter.date(from: string) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd"
            return outputFormatter.string(from: date)
        }
        return nil
    }
    

    private var locationTips: some View {
        TabView {
            ForEach(location.tips) { tip in
                VStack(spacing: 5) {
                    Text(tip.text)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true) // Allow the text view to size to fit its content
                    
                    Text(formatDate(from: tip.created_at) ?? "")
                        .font(.caption)
                        .padding(.top, 5)
                }
                .padding()
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: self.tabViewHeight)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
        .cornerRadius(10)
    }
    
    private func findSelectedImageIndex() -> Int {
        guard let image = selectedImage, let index = location.photos.firstIndex(of: image) else {
            return 0
        }
        return index
    }
    
    private var locationPhotos: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(location.photos, id: \.id) { image in
                    AsyncImage(url: URL(string: "\(image.prefix)90x90\(image.suffix)")) { phase in
                        switch phase {
                        case .success(let imageView):
                            imageView
                                .aspectRatio(contentMode: .fit)
                                .frame(width:70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 10)
                                .onTapGesture {
                                    print("Tapped on: \(image.prefix)\(image.suffix)")
                                    selectedImage = image
                                }
                        case .empty:
                            EmptyView()
                        case .failure:
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .padding(.horizontal, 2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
        .cornerRadius(10)
        .sheet(item: $selectedImage, onDismiss: {
            selectedIndex = 0
        }) { _ in  // Since we are not directly using the 'selectedImage' inside the closure
            VStack {
                TabView(selection: $selectedIndex) {
                    ForEach(location.photos.indices, id: \.self) { index in
                        let currentImage = location.photos[index]
                        AsyncImage(url: URL(string: "\(currentImage.prefix)\(currentImage.width)x\(currentImage.height)\(currentImage.suffix)")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .shadow(radius: 10)
                            case .empty, .failure:
                                // Placeholder or error image here
                                Color.gray
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .onAppear {
                    selectedIndex = location.photos.firstIndex(where: { $0.id == selectedImage?.id }) ?? 0
                }
                Text(formatDate(from: location.photos[selectedIndex].created_at) ?? "")
                    .padding()
            }
        }
    }
}
