//
//  WeatherInteractor.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation
import CoreLocation

class WeatherInteractor: WeatherInteractorInputProtocol {
    weak var presenter: WeatherInteractorOutputProtocol?
    var locationService: LocationServiceProtocol
    var networkService: NetworkServiceProtocol

    private var hasAttemptedLocationFetch = false

    init(locationService: LocationServiceProtocol, networkService: NetworkServiceProtocol) {
        self.locationService = locationService
        self.networkService = networkService
        self.locationService.delegate = self
    }

    func fetchWeatherDataForCurrentLocation() {
        locationService.requestLocationPermission()
    }
    
    func fetchWeatherDataForDefaultLocation() {
        let moscow = locationService.defaultLocation
        fetchWeatherData(latitude: moscow.latitude, longitude: moscow.longitude)
    }

    private func fetchWeatherData(latitude: Double, longitude: Double) {
        networkService.fetchWeatherData(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self?.presenter?.didFetchWeatherData(weatherData)
                case .failure(let error):
                    self?.presenter?.didFailToFetchWeatherData(.networkError(error))
                }
            }
        }
    }
}

// MARK: - LocationServiceDelegate
extension WeatherInteractor: LocationServiceDelegate {
    func didUpdateLocation(latitude: Double, longitude: Double) {
        presenter?.didUpdateLocation(latitude: latitude, longitude: longitude)
        fetchWeatherData(latitude: latitude, longitude: longitude)
    }

    func didFailWithError(_ error: LocationError) {
        presenter?.didFailToUpdateLocation(error)
    }
}
