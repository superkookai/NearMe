//
//  MapUtilities.swift
//  NearMe
//
//  Created by Weerawut Chaiyasomboon on 01/04/2568.
//

import Foundation
import MapKit

func performSearch(searchTerm: String, visibleRegion: MKCoordinateRegion?) async throws -> [MKMapItem] {
    guard let region = visibleRegion else { return [] }
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchTerm
    request.resultTypes = .pointOfInterest
    request.region = region
    
    let search = MKLocalSearch(request: request)
    let response = try await search.start()
    
    return response.mapItems
}

func calculateDistance(from: CLLocation, to: CLLocation) -> Measurement<UnitLength> {
    let distanceInMeters = from.distance(from: to)
    return Measurement(value: distanceInMeters, unit: .meters)
}

func calculateDirections(from: MKMapItem, to: MKMapItem) async -> MKRoute? {
    let directionRequest = MKDirections.Request()
    directionRequest.transportType = .automobile
    directionRequest.source = from
    directionRequest.destination = to
    
    let directions = MKDirections(request: directionRequest)
    let response = try? await directions.calculate()
    
    return response?.routes.first
}

func makeCall(phoneNumber: String) {
    if let url = URL(string: "tel://\(phoneNumber)") {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Device cannot make phone call")
        }
    }
}
