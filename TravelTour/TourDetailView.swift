//
//  TourDetailView.swift
//  TravelTour
//
//  Created by The Wiggses on 7/16/25.
//


//
//  TourDetailView.swift
//  CityTourApp
//
//  Created by Gemini on 2025-07-16.
//

import SwiftUI
import MapKit // For displaying maps

/// A view to display the detailed information of a single tour stop.
struct TourDetailView: View {
    let tourStop: TourStop

    // State for the map region
    @State private var region: MKCoordinateRegion

    init(tourStop: TourStop) {
        self.tourStop = tourStop
        // Initialize the map region to center on the tour stop's coordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: tourStop.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Zoom level
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Display image if available
                if let imageName = tourStop.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                } else {
                    // Placeholder if no image name is provided
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .cornerRadius(15)
                        .overlay(Text("No Image Available").foregroundColor(.white))
                }

                Text(tourStop.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                Text(tourStop.description)
                    .font(.body)
                    .foregroundColor(.secondary)

                Divider()

                Text("Location on Map")
                    .font(.headline)

                // Display a map centered on the tour stop
                Map(coordinateRegion: $region, annotationItems: [tourStop]) { stop in
                    MapMarker(coordinate: stop.coordinate, tint: .red) // Pin for the tour stop
                }
                .frame(height: 300) // Fixed height for the map
                .cornerRadius(15)
                .shadow(radius: 3)
                .disabled(true) // Prevent map interaction in this view for simplicity

                // Button to open in Apple Maps
                Button(action: {
                    // Action to open in Apple Maps
                    let placemark = MKPlacemark(coordinate: tourStop.coordinate)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = tourStop.name
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
                }) {
                    Label("Get Directions", systemImage: "map.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle(tourStop.name)
        .navigationBarTitleDisplayMode(.inline) // Keep title inline
    }
}

// MARK: - Preview Provider (for Xcode Canvas)
struct TourDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TourDetailView(tourStop: TourStop(
                name: "Sample Place of Interest",
                description: "This is a sample description for a local landmark. It can be quite long and detailed, providing interesting facts and historical context about the location.",
                coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
                imageName: nil // Or "millenniumPark" if you have it
            ))
        }
    }
}
