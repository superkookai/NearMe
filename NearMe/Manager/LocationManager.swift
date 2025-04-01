//
//  LocationManager.swift
//  NearMe
//
//  Created by Weerawut Chaiyasomboon on 01/04/2568.
//

import Foundation
import MapKit
import SwiftUI

enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case unknownLocation
    case accessDenied
    case network
    case operationFailed
    
    var errorDescription: String? {
        switch self {
            case .authorizationDenied:
                return NSLocalizedString("Location access denied.", comment: "")
            case .authorizationRestricted:
                return NSLocalizedString("Location access restricted.", comment: "")
            case .unknownLocation:
                return NSLocalizedString("Unknown location.", comment: "")
            case .accessDenied:
                return NSLocalizedString("Access denied.", comment: "")
            case .network:
                return NSLocalizedString("Network failed.", comment: "")
            case .operationFailed:
                return NSLocalizedString("Operation failed.", comment: "")
        }
    }
}

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    static let shared = LocationManager()
    var region = MKCoordinateRegion()
    var error: LocationError?
    
    private override init() {
        super.init()
        self.manager.delegate = self
    }
}

extension LocationManager {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            self.manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            self.manager.requestLocation()
        case .denied:
            error = .authorizationDenied
        case .restricted:
            error = .authorizationRestricted
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map { location in
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                self.error = .unknownLocation
            case .denied:
                self.error = .accessDenied
            case .network:
                self.error = .network
            default:
                self.error = .operationFailed
            }
        }
    }
}
