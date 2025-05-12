//
//  LocationService.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation
import CoreLocation

enum LocationError: Error, Equatable {
    case authorizationDenied
    case authorizationRestricted
    case locationUnknown
    case serviceDisabled
    case coreLocationError(Error)

    static func == (lhs: LocationError, rhs: LocationError) -> Bool {
        switch (lhs, rhs) {
        case (.authorizationDenied, .authorizationDenied):
            return true
        case (.authorizationRestricted, .authorizationRestricted):
            return true
        case (.locationUnknown, .locationUnknown):
            return true
        case (.serviceDisabled, .serviceDisabled):
            return true
        case (.coreLocationError(_), .coreLocationError(_)):
            return true
        default:
            return false
        }
    }
}

protocol LocationServiceDelegate: AnyObject {
    func didUpdateLocation(latitude: Double, longitude: Double)
    func didFailWithError(_ error: LocationError)
}

protocol LocationServiceProtocol: AnyObject {
    var delegate: LocationServiceDelegate? { get set }
    var defaultLocation: (latitude: Double, longitude: Double) { get }
    func requestLocationPermission()
    func startUpdatingLocation()
    func getCurrentAuthorizationStatus() -> CLAuthorizationStatus
}

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    weak var delegate: LocationServiceDelegate?
    let defaultLocation: (latitude: Double, longitude: Double) = (55.7558, 37.6173)

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    private func authStatusToString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown"
        }
    }

    func getCurrentAuthorizationStatus() -> CLAuthorizationStatus {
        let status = locationManager.authorizationStatus
        return status
    }

    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                 startUpdatingLocation()
            case .denied:
                delegate?.didFailWithError(.authorizationDenied)
            case .restricted:
                delegate?.didFailWithError(.authorizationRestricted)
            @unknown default:
                 delegate?.didFailWithError(.authorizationDenied)
        }
    }

    func startUpdatingLocation() {

        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(.serviceDisabled)
                }
                return
            }

            DispatchQueue.main.async {
                self.continueUpdatingLocation()
            }
        }
    }

    private func continueUpdatingLocation() {
        let status = locationManager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            handleAuthorizationStatus(status)
            return
        }

        locationManager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            delegate?.didFailWithError(.locationUnknown)
            return
        }
        delegate?.didUpdateLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown {
             print("LocationService: CLError.locationUnknown - often temporary.")
        } else {
             delegate?.didFailWithError(.coreLocationError(error))
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        handleAuthorizationStatus(newStatus)
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
         switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                startUpdatingLocation()
            case .denied:
                delegate?.didFailWithError(.authorizationDenied)
            case .restricted:
                delegate?.didFailWithError(.authorizationRestricted)
            case .notDetermined:
                break
            @unknown default:
                 delegate?.didFailWithError(.authorizationDenied)
        }
    }
}
