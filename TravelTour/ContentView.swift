//
//  ContentView.swift
//  CityTourApp
//
//  Created by Gemini on 2025-07-16.
//

import SwiftUI
import CoreLocation
import MapKit

/// The main content view of the application, displaying a list of tour stops.
struct ContentView: View {
    // Observe changes in the TourViewModel
    @StateObject var viewModel = TourViewModel()

    var body: some View {
        NavigationView {
            List {
                // Iterate over the tour stops provided by the ViewModel
                ForEach(viewModel.tourStops) { stop in
                    // NavigationLink allows tapping a row to go to a detail view
                    NavigationLink(destination: TourDetailView(tourStop: stop)) {
                        HStack {
                            // Display a small image if available
                            if let imageName = stop.imageName {
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)
                                    .clipped() // Ensures image stays within bounds
                            } else {
                                // Placeholder for no image
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                                    .cornerRadius(10)
                            }

                            VStack(alignment: .leading) {
                                Text(stop.name)
                                    .font(.headline)
                                Text(stop.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2) // Limit description to 2 lines
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Chicago Brewery Tour")
            .onAppear {
                // Optionally fetch data when the view appears
                // viewModel.fetchTourStops()
            }
        }
    }
}

// MARK: - Preview Provider (for Xcode Canvas)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/****
//
//  ContentView.swift
//  TourApp
//
//  Created by Gemini on 2025-07-16.
//

import SwiftUI
import CoreLocation
import MapKit // Import MapKit for map and directions functionality

// MARK: - TourStop Struct
/// Represents a single tour stop with a name and geographical coordinates.
struct TourStop: Identifiable {
    let id = UUID() // Unique identifier for SwiftUI List
    let name: String
    let coordinate: CLLocationCoordinate2D

    /// Initializes a TourStop with a name, latitude, and longitude.
    init(name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - LocationManager Class
/// Manages location services, including requesting authorization,
/// getting current location, and monitoring location changes.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    // Published properties to update SwiftUI views automatically
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var currentLocation: CLLocation?
    @Published var route: MKRoute? // To store the calculated route for navigation
    @Published var directions: [String] = [] // To store turn-by-turn directions

    override init() {
        super.init()
        locationManager.delegate = self // Set the delegate to receive location updates
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // High accuracy for navigation
        locationManager.distanceFilter = 10 // Update every 10 meters
    }

    /// Requests "When In Use" location authorization from the user.
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Starts updating the user's location.
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    /// Stops updating the user's location to save battery.
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate Methods

    /// Called when the authorization status for the app changes.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location authorization granted.")
            startUpdatingLocation() // Start updating location once authorized
        case .denied, .restricted:
            print("Location authorization denied or restricted.")
            // Handle denied/restricted state, e.g., show an alert
        case .notDetermined:
            print("Location authorization not determined.")
            requestLocationAuthorization() // Request if not determined
        @unknown default:
            print("Unknown authorization status.")
        }
    }

    /// Called when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        print("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    /// Called when an error occurs while getting location data.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    // MARK: - Navigation Methods

    /// Calculates and displays a route from the current location to a destination.
    /// - Parameter destinationCoordinate: The coordinates of the destination.
    func calculateRoute(to destinationCoordinate: CLLocationCoordinate2D) {
        guard let userLocation = currentLocation else {
            print("Current location not available to calculate route.")
            return
        }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .walking // Or .automobile, .transit, .any

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error calculating route: \(error.localizedDescription)")
                self.route = nil
                self.directions = []
                return
            }

            guard let route = response?.routes.first else {
                print("No route found.")
                self.route = nil
                self.directions = []
                return
            }

            self.route = route
            self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
            print("Route calculated. Number of steps: \(route.steps.count)")
        }
    }
}

// MARK: - ContentView
/// The main SwiftUI view for the application.
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    // Predefined tour stops
    let tourStops: [TourStop] = [
        TourStop(name: "Millennium Park", latitude: 41.8826, longitude: -87.6225),
        TourStop(name: "Art Institute of Chicago", latitude: 41.8796, longitude: -87.6237),
        TourStop(name: "Cloud Gate (The Bean)", latitude: 41.8827, longitude: -87.6233),
        TourStop(name: "Navy Pier", latitude: 41.8917, longitude: -87.6089)
    ]

    @State private var selectedTourStop: TourStop? // State to hold the currently selected tour stop

    var body: some View {
        VStack {
            // MARK: - Current Location Section
            Text("Current Location")
                .font(.headline)
                .padding(.bottom, 5)

            if let location = locationManager.currentLocation {
                Text("Latitude: \(location.coordinate.latitude, specifier: "%.6f")")
                Text("Longitude: \(location.coordinate.longitude, specifier: "%.6f")")
                Text("Altitude: \(location.altitude, specifier: "%.2f") m")
                Text("Speed: \(location.speed, specifier: "%.2f") m/s")
            } else {
                Text("Fetching location...")
            }

            // MARK: - Tour Stops List
            List(tourStops) { stop in
                VStack(alignment: .leading) {
                    Text(stop.name)
                        .font(.subheadline)
                    if let currentLocation = locationManager.currentLocation {
                        let distance = currentLocation.distance(from: CLLocation(latitude: stop.coordinate.latitude, longitude: stop.coordinate.longitude))
                        Text("Distance: \(distance / 1000, specifier: "%.2f") km")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Distance: N/A")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .onTapGesture {
                    selectedTourStop = stop // Set the selected tour stop
                    locationManager.calculateRoute(to: stop.coordinate) // Calculate route to selected stop
                }
            }
            .frame(height: 200) // Limit list height

            // MARK: - Map View
            // Display a map with the current location and the calculated route
            MapView(
                coordinate: locationManager.currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 41.881832, longitude: -87.629798), // Default to Chicago if no location
                route: locationManager.route,
                destinationCoordinate: selectedTourStop?.coordinate
            )
            .edgesIgnoringSafeArea(.all)
            .frame(height: 300) // Set a fixed height for the map

            // MARK: - Navigation Directions
            if !locationManager.directions.isEmpty {
                Text("Turn-by-Turn Directions:")
                    .font(.headline)
                    .padding(.top, 10)
                List(locationManager.directions, id: \.self) { instruction in
                    Text(instruction)
                }
                .frame(height: 150) // Limit directions list height
            }
        }
        .padding()
        .onAppear {
            // Request authorization and start updating location when the view appears
            locationManager.requestLocationAuthorization()
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            // Stop updating location when the view disappears to save battery
            locationManager.stopUpdatingLocation()
        }
    }
}

// MARK: - MapView
/// A SwiftUI `UIViewRepresentable` to integrate `MKMapView`.
/// This allows us to use UIKit's `MKMapView` within SwiftUI.
struct MapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D // User's current location
    var route: MKRoute? // The route to display
    var destinationCoordinate: CLLocationCoordinate2D? // The destination marker

    /// Creates and configures the `MKMapView`.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator // Set the delegate for annotations and overlays
        mapView.showsUserLocation = true // Show the blue dot for the user's location
        return mapView
    }

    /// Updates the `MKMapView` when SwiftUI state changes.
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Set the region to center the map on the user's location
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)

        // Clear existing overlays and annotations before adding new ones
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        // Add destination annotation if available
        if let destination = destinationCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = destination
            annotation.title = "Destination"
            uiView.addAnnotation(annotation)
        }

        // Add route overlay if a route exists
        if let route = route {
            uiView.addOverlay(route.polyline)
            // Optionally, zoom to fit the route
            uiView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        }
    }

    /// Creates a `Coordinator` to handle `MKMapViewDelegate` methods.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator Class
    /// A helper class to act as the `MKMapViewDelegate`.
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        /// Renders the route polyline on the map.
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue // Route line color
                renderer.lineWidth = 5 // Route line width
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - App Entry Point
//
//  TourAppApp.swift
//  TourApp
//
//  Created by Gemini on 2025-07-16.
//

import SwiftUI

@main
struct TourAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

*/
