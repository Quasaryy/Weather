//
//  WeatherProtocols.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//


import Foundation
import CoreLocation

// MARK: - View Output
protocol WeatherViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func displayWeather(currentWeather: CurrentWeatherViewModel, hourlyForecast: [HourlyWeatherViewModel], dailyForecast: [DailyWeatherViewModel], locationName: String)
    func showError(message: String)
}

// MARK: - View Input
protocol WeatherPresenterProtocol: AnyObject {
    var view: WeatherViewProtocol? { get set }
    var interactor: WeatherInteractorInputProtocol? { get set }
    // var router: WeatherRouterProtocol? { get set } // Пока нету роутера

    func viewDidLoad()
    func didTapRetry()
}

// MARK: - Interactor Input
protocol WeatherInteractorInputProtocol: AnyObject {
    var presenter: WeatherInteractorOutputProtocol? { get set }
    var locationService: LocationServiceProtocol { get set }
    var networkService: NetworkServiceProtocol { get set }

    func fetchWeatherDataForCurrentLocation()
    func fetchWeatherDataForDefaultLocation() // Для Москвы, если геолокация не удалась
}

// MARK: - Interactor Output
protocol WeatherInteractorOutputProtocol: AnyObject {
    func didFetchWeatherData(_ weatherData: WeatherForecastResponse)
    func didFailToFetchWeatherData(_ error: WeatherError)
    func didUpdateLocation(latitude: Double, longitude: Double)
    func didFailToUpdateLocation(_ error: LocationError)
}

// MARK: - Router
/*
protocol WeatherRouterProtocol: AnyObject {
    static func createWeatherModule() -> UIViewController
    // func navigateToSettings(from view: WeatherViewProtocol)
}
*/

// MARK: - ViewModels

struct CurrentWeatherViewModel {
    let temperature: String
    let conditionText: String
    let conditionIconURL: URL?
    let feelsLike: String
    let windSpeed: String
    let humidity: String
    let pressure: String
}

struct HourlyWeatherViewModel {
    let time: String
    let temperature: String
    let conditionIconURL: URL?
}

struct DailyWeatherViewModel {
    let dayOfWeek: String
    let date: String
    let minTemp: String
    let maxTemp: String
    let conditionIconURL: URL?
    let chanceOfRain: String?
}
