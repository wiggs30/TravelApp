//
//  TourStop.swift
//  TravelTour
//
//  Created by The Wiggses on 7/16/25.
//


//
//  TourStop.swift
//  CityTourApp
//
//  Created by Gemini on 2025-07-16.
//

import Foundation
import CoreLocation // Used for CLLocationCoordinate2D

/// Represents a single point of interest in the city tour.
struct TourStop: Identifiable {
    let id = UUID() // Unique identifier for each tour stop
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D // Geographical coordinates of the stop
    let imageName: String? // Optional image name for the stop
}
