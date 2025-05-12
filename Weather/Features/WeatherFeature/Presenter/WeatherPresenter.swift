//
//  WeatherPresenter.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation
import CoreLocation

class WeatherPresenter: WeatherPresenterProtocol {
    weak var view: WeatherViewProtocol?
    var interactor: WeatherInteractorInputProtocol?
    // var router: WeatherRouterProtocol? // Пока не используется
    
    private var currentWeatherData: WeatherForecastResponse?
    
    // MARK: - WeatherPresenterProtocol
    func viewDidLoad() {
        view?.showLoading()
        interactor?.fetchWeatherDataForCurrentLocation()
    }
    
    func didTapRetry() {
        view?.showLoading()
        interactor?.fetchWeatherDataForCurrentLocation()
    }
    
    // MARK: - Helpers
    
    private func processWeatherData(_ data: WeatherForecastResponse) {
        self.currentWeatherData = data
        view?.hideLoading()
        view?.displayWeather(currentWeather: WeatherDataMapper.current(from: data.current, location: data.location), hourlyForecast: WeatherDataMapper.hourly(from: data.forecast), dailyForecast: WeatherDataMapper.daily(from: data.forecast.forecastday), locationName: data.location.name)
    }
}

// MARK: - WeatherInteractorOutputProtocol
extension WeatherPresenter: WeatherInteractorOutputProtocol {
    func didFetchWeatherData(_ weatherData: WeatherForecastResponse) {
        processWeatherData(weatherData)
    }

    func didFailToFetchWeatherData(_ error: WeatherError) {
        let message = ErrorTranslator.message(for: error)
        view?.hideLoading()
        view?.showError(message: message)
    }
    
    func didUpdateLocation(latitude: Double, longitude: Double) {
        print("WeatherPresenter (InteractorOutput): didUpdateLocation - lat: \(latitude), lon: \(longitude).")
    }

    func didFailToUpdateLocation(_ error: LocationError) {
        let message = ErrorTranslator.message(for: .locationError(error))
        view?.showLoading()
        interactor?.fetchWeatherDataForDefaultLocation()
    }
}

// MARK: - Date Formatters
extension DateFormatter {
    static let yyyyMMddHHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    static let HHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    static let EEEE: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    static let ddMM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}
