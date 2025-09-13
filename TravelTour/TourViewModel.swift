//
//  TourViewModel.swift
//  TravelTour
//
//  Created by The Wiggses on 7/16/25.
//


//
//  TourViewModel.swift
//  CityTourApp
//
//  Created by Gemini on 2025-07-16.
//

import Foundation
import CoreLocation

/// ViewModel to manage and provide tour stop data.
/// In a real application, this would handle data fetching (e.g., from an API or database).
class TourViewModel: ObservableObject {
    @Published var tourStops: [TourStop]

    init() {
        // Initialize with some sample tour stops.
        // In a real app, this data would likely be loaded dynamically.
        self.tourStops = [
            TourStop(
                name: "Off Color Brewery",
                description: "Taproom in the heart of Lincoln Park, offering a wide variety of craft beers and a lively atmosphere.",
                coordinate: CLLocationCoordinate2D(latitude: 41.8826, longitude: -87.6223),
                imageName: "offcolor"
            ),
            TourStop(
                name: "Marz Community Brewing Company",
                description: "Adventurous ales and other styles brewed on-site.",
                coordinate: CLLocationCoordinate2D(latitude: 41.8795, longitude: -87.6237),
                imageName: "marzcommunity"
            ),
            TourStop(
                name: "Navy Pier",
                description: "A 3,300-foot-long pier on the Chicago shoreline of Lake Michigan, featuring rides, restaurants, and entertainment.",
                coordinate: CLLocationCoordinate2D(latitude: 41.8917, longitude: -87.6089),
                imageName: "gooseisland"
            ),
            TourStop(
                name: "Willis Tower Skydeck",
                description: "Experience breathtaking views of Chicago from the 103rd floor of the Willis Tower, including The Ledge glass boxes.",
                coordinate: CLLocationCoordinate2D(latitude: 41.8789, longitude: -87.6359),
                imageName: "willisTower"
            ),
            TourStop(
                name: "Magnificent Mile",
                description: "A section of Michigan Avenue known for its upscale shops, restaurants, museums, and hotels.",
                coordinate: CLLocationCoordinate2D(latitude: 41.8958, longitude: -87.6237),
                imageName: "magnificentMile"
            )
        ]
    }

    /// Placeholder for fetching tour stops from a remote source.
    /// In a real app, this would be an asynchronous operation.
    func fetchTourStops() {
        // Simulate a network request or database fetch
        print("Fetching places of interest...")
        // After fetching, update self.tourStops
    }

    /// Placeholder for getting the user's current location.
    /// This would typically involve CoreLocationManager.
    func getUserLocation() -> CLLocationCoordinate2D? {
        // In a real app, you'd use CLLocationManager to get the actual user location.
        // For now, returning a dummy location or nil.
        print("Getting your current location...")
        return nil // Or return a dummy coordinate for testing, e.g., CLLocationCoordinate2D(latitude: 41.88, longitude: -87.62)
    }
}
