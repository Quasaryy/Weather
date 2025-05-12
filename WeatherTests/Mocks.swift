//
//  Mocks.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation
import CoreLocation
@testable import Weather

// MARK: - Mock WeatherViewProtocol
class MockWeatherView: WeatherViewProtocol {
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var displayWeatherCalled = false
    var showErrorCalled = false

    var receivedCurrentWeather: CurrentWeatherViewModel?
    var receivedHourlyForecast: [HourlyWeatherViewModel]?
    var receivedDailyForecast: [DailyWeatherViewModel]?
    var receivedLocationName: String?
    var receivedErrorMessage: String?

    var showLoadingCalledAction: (() -> Void)?
    var hideLoadingCalledAction: (() -> Void)?
    var displayWeatherCalledAction: (() -> Void)?
    var showErrorCalledAction: (() -> Void)?

    func showLoading() {
        showLoadingCalled = true
        showLoadingCalledAction?()
    }

    func hideLoading() {
        hideLoadingCalled = true
        hideLoadingCalledAction?()
    }

    func displayWeather(currentWeather: CurrentWeatherViewModel, hourlyForecast: [HourlyWeatherViewModel], dailyForecast: [DailyWeatherViewModel], locationName: String) {
        displayWeatherCalled = true
        receivedCurrentWeather = currentWeather
        receivedHourlyForecast = hourlyForecast
        receivedDailyForecast = dailyForecast
        receivedLocationName = locationName
        displayWeatherCalledAction?()
    }

    func showError(message: String) {
        showErrorCalled = true
        receivedErrorMessage = message
        showErrorCalledAction?()
    }

    func reset() {
        showLoadingCalled = false
        hideLoadingCalled = false
        displayWeatherCalled = false
        showErrorCalled = false
        receivedCurrentWeather = nil
        receivedHourlyForecast = nil
        receivedDailyForecast = nil
        receivedLocationName = nil
        receivedErrorMessage = nil
        showLoadingCalledAction = nil
        hideLoadingCalledAction = nil
        displayWeatherCalledAction = nil
        showErrorCalledAction = nil
    }
}

// MARK: - Mock WeatherInteractorInputProtocol
class MockWeatherInteractor: WeatherInteractorInputProtocol {
    var presenter: WeatherInteractorOutputProtocol?
    var locationService: LocationServiceProtocol = MockLocationService()
    var networkService: NetworkServiceProtocol = MockNetworkService()

    var fetchWeatherDataForCurrentLocationCalled = false
    var fetchWeatherDataForDefaultLocationCalled = false

    func fetchWeatherDataForCurrentLocation() {
        fetchWeatherDataForCurrentLocationCalled = true
    }

    func fetchWeatherDataForDefaultLocation() {
        fetchWeatherDataForDefaultLocationCalled = true
    }

    func reset() {
        fetchWeatherDataForCurrentLocationCalled = false
        fetchWeatherDataForDefaultLocationCalled = false
    }
}

// MARK: - Mock WeatherInteractorOutputProtocol
class MockWeatherPresenterOutput: WeatherInteractorOutputProtocol {
    var didFetchWeatherDataCalled = false
    var didFailToFetchWeatherDataCalled = false
    var didUpdateLocationCalled = false
    var didFailToUpdateLocationCalled = false

    var receivedWeatherData: WeatherForecastResponse?
    var receivedWeatherError: WeatherError?
    var receivedLatitude: Double?
    var receivedLongitude: Double?
    var receivedLocationError: LocationError?

    var didFetchWeatherDataCalledAction: (() -> Void)?
    var didFailToFetchWeatherDataCalledAction: (() -> Void)?
    var didUpdateLocationCalledAction: (() -> Void)?
    var didFailToUpdateLocationCalledAction: (() -> Void)?

    func didFetchWeatherData(_ weatherData: WeatherForecastResponse) {
        didFetchWeatherDataCalled = true
        receivedWeatherData = weatherData
        didFetchWeatherDataCalledAction?()
    }

    func didFailToFetchWeatherData(_ error: WeatherError) {
        didFailToFetchWeatherDataCalled = true
        receivedWeatherError = error
        didFailToFetchWeatherDataCalledAction?()
    }

    func didUpdateLocation(latitude: Double, longitude: Double) {
        didUpdateLocationCalled = true
        receivedLatitude = latitude
        receivedLongitude = longitude
        didUpdateLocationCalledAction?()
    }

    func didFailToUpdateLocation(_ error: LocationError) {
        didFailToUpdateLocationCalled = true
        receivedLocationError = error
        didFailToUpdateLocationCalledAction?()
    }

    func reset() {
        didFetchWeatherDataCalled = false
        didFailToFetchWeatherDataCalled = false
        didUpdateLocationCalled = false
        didFailToUpdateLocationCalled = false
        receivedWeatherData = nil
        receivedWeatherError = nil
        receivedLatitude = nil
        receivedLongitude = nil
        receivedLocationError = nil
        didFetchWeatherDataCalledAction = nil
        didFailToFetchWeatherDataCalledAction = nil
        didUpdateLocationCalledAction = nil
        didFailToUpdateLocationCalledAction = nil
    }
}


// MARK: - Mock LocationServiceProtocol
class MockLocationService: LocationServiceProtocol {
    weak var delegate: LocationServiceDelegate?
    var defaultLocation: (latitude: Double, longitude: Double) = (latitude: 55.75, longitude: 37.62)

    var requestLocationPermissionCalled = false
    var startUpdatingLocationCalled = false
    var getCurrentAuthorizationStatusCalled = false

    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined

    func requestLocationPermission() {
        requestLocationPermissionCalled = true
    }

    func startUpdatingLocation() {
        startUpdatingLocationCalled = true
    }

    func getCurrentAuthorizationStatus() -> CLAuthorizationStatus {
        getCurrentAuthorizationStatusCalled = true
        return mockAuthorizationStatus
    }


    func simulateLocationUpdate(lat: Double, lon: Double) {
        delegate?.didUpdateLocation(latitude: lat, longitude: lon)
    }

    func simulateLocationError(error: LocationError) {
        delegate?.didFailWithError(error)
    }

     func reset() {
        requestLocationPermissionCalled = false
        startUpdatingLocationCalled = false
        getCurrentAuthorizationStatusCalled = false
        mockAuthorizationStatus = .notDetermined
    }
}

// MARK: - Mock NetworkServiceProtocol
class MockNetworkService: NetworkServiceProtocol {
    var fetchWeatherDataCalled = false
    var receivedLatitude: Double?
    var receivedLongitude: Double?

    var weatherResult: Result<WeatherForecastResponse, NetworkError>?

    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherForecastResponse, NetworkError>) -> Void) {
        fetchWeatherDataCalled = true
        receivedLatitude = latitude
        receivedLongitude = longitude

        if let result = weatherResult {
            DispatchQueue.main.async {
                 completion(result)
            }
        } else {
            fatalError("MockNetworkService requires weatherResult to be set for the test.")
        }
    }

    func reset() {
        fetchWeatherDataCalled = false
        receivedLatitude = nil
        receivedLongitude = nil
        weatherResult = nil
    }
}

// MARK: - Mock KeychainServiceProtocol
class MockKeychainService: KeychainServiceProtocol {
    var apiKey: String? = "test_api_key"

    var saveAPIKeyCalled = false
    var getAPIKeyCalled = false
    var deleteAPIKeyCalled = false
    var savedKey: String?

    func saveAPIKey(_ key: String) -> Bool {
        saveAPIKeyCalled = true
        savedKey = key
        self.apiKey = key
        return true
    }

    func getAPIKey() -> String? {
        getAPIKeyCalled = true
        return apiKey
    }

    func deleteAPIKey() -> Bool {
        deleteAPIKeyCalled = true
        apiKey = nil
        return true
    }

    func reset() {
        saveAPIKeyCalled = false
        getAPIKeyCalled = false
        deleteAPIKeyCalled = false
        savedKey = nil
        apiKey = "test_api_key"
    }
}


// MARK: - Test Data Factory
enum TestDataFactory {

    static func createSampleWeatherResponse(
        locationName: String = "TestCity",
        tempC: Double = 15.0,
        conditionText: String = "Sunny",
        icon: String = "//cdn.weatherapi.com/weather/64x64/day/113.png",
        feelsLikeC: Double = 14.0,
        windKph: Double = 10.0,
        windDir: String = "W",
        humidity: Int = 50,
        pressureMb: Double = 1012.0,
        hourlyForecastCount: Int = 24,
        dailyForecastCount: Int = 7
    ) -> WeatherForecastResponse {

        let location = Location(name: locationName, region: "TestRegion", country: "TestCountry", lat: 50.0, lon: 0.0, tz_id: "Europe/London", localtime_epoch: 1678886400, localtime: "2023-03-15 13:00")
        let condition = Condition(text: conditionText, icon: icon, code: 1000)
        let current = CurrentWeather(last_updated_epoch: 1678886400, last_updated: "2023-03-15 13:00", temp_c: tempC, temp_f: 60.0, is_day: 1, condition: condition, wind_mph: 6.2, wind_kph: windKph, wind_degree: 270, wind_dir: windDir, pressure_mb: pressureMb, pressure_in: 29.88, precip_mm: 0.0, precip_in: 0.0, humidity: humidity, cloud: 0, feelslike_c: feelsLikeC, feelslike_f: 57.0, vis_km: 10.0, vis_miles: 6.0, uv: 5.0, gust_mph: 9.3, gust_kph: 15.0)

        var forecastDays: [ForecastDay] = []
        let calendar = Calendar.current
        let startDate = Date()

        for i in 0..<dailyForecastCount {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            let dateString = DateFormatter.yyyyMMdd.string(from: date)

            var hours: [HourWeather] = []
            if i < 2 {
                for h in 0..<24 {
                    let hourDate = calendar.date(byAdding: .hour, value: h, to: calendar.startOfDay(for: date))!
                    let hourTimeString = DateFormatter.yyyyMMddHHmm.string(from: hourDate)
                     hours.append(HourWeather(time_epoch: Int(hourDate.timeIntervalSince1970), time: hourTimeString, temp_c: tempC + Double(h % 5 - 2), temp_f: 60.0, is_day: (h > 6 && h < 18) ? 1 : 0, condition: condition, wind_mph: 6.2, wind_kph: 10.0, wind_degree: 270, wind_dir: "W", pressure_mb: 1012.0, pressure_in: 29.88, precip_mm: 0.0, precip_in: 0.0, snow_cm: 0.0, humidity: 50, cloud: 0, feelslike_c: 14.0, feelslike_f: 57.0, windchill_c: 14.0, windchill_f: 57.0, heatindex_c: 14.0, heatindex_f: 57.0, dewpoint_c: 5.0, dewpoint_f: 41.0, will_it_rain: 0, chance_of_rain: i * 5, will_it_snow: 0, chance_of_snow: 0, vis_km: 10.0, vis_miles: 6.0, gust_mph: 9.3, gust_kph: 15.0, uv: 5.0))
                }
            }


            let dayWeather = DayWeather(maxtemp_c: tempC + 5, maxtemp_f: 70.0, mintemp_c: tempC - 2, mintemp_f: 55.0, avgtemp_c: tempC + 1, avgtemp_f: 62.0, maxwind_mph: 15.0, maxwind_kph: 24.1, totalprecip_mm: Double(i % 2), totalprecip_in: 0.0, totalsnow_cm: 0.0, avgvis_km: 10.0, avgvis_miles: 6.0, avghumidity: Double(humidity + i * 2), daily_will_it_rain: (i * 5 > 30) ? 1: 0, daily_chance_of_rain: i * 10, daily_will_it_snow: 0, daily_chance_of_snow: 0, condition: condition, uv: 5.0)
            let astro = Astro(sunrise: "06:00 AM", sunset: "06:00 PM", moonrise: "07:00 PM", moonset: "07:00 AM", moon_phase: "Full Moon", moon_illumination: 100, is_moon_up: 1, is_sun_up: 1)

            forecastDays.append(ForecastDay(date: dateString, date_epoch: Int(calendar.startOfDay(for: date).timeIntervalSince1970), day: dayWeather, astro: astro, hour: hours))
        }

        let forecast = Forecast(forecastday: forecastDays)
        return WeatherForecastResponse(location: location, current: current, forecast: forecast)
    }
}

// MARK: - DateFormatter Extension Access
extension DateFormatter {
    static func testable_yyyyMMddHHmm() -> DateFormatter { yyyyMMddHHmm }
    static func testable_HHmm() -> DateFormatter { HHmm }
    static func testable_yyyyMMdd() -> DateFormatter { yyyyMMdd }
    static func testable_EEEE() -> DateFormatter { EEEE }
    static func testable_ddMM() -> DateFormatter { ddMM }
}
