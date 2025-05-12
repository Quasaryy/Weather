//
//  WeatherInteractorTests.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import XCTest
import CoreLocation
@testable import Weather

class WeatherInteractorTests: XCTestCase {

    var sut: WeatherInteractor!
    var mockPresenter: MockWeatherPresenterOutput!
    var mockLocationService: MockLocationService!
    var mockNetworkService: MockNetworkService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPresenter = MockWeatherPresenterOutput()
        mockLocationService = MockLocationService()
        mockNetworkService = MockNetworkService()
        sut = WeatherInteractor(locationService: mockLocationService, networkService: mockNetworkService)
        sut.presenter = mockPresenter
        mockLocationService.delegate = sut
    }

    override func tearDownWithError() throws {
        sut = nil
        mockPresenter = nil
        mockLocationService = nil
        mockNetworkService = nil
        try super.tearDownWithError()
    }

    // MARK: - Presenter -> Interactor Calls

    func testFetchWeatherDataForCurrentLocation_CallsRequestLocationPermission() {
        // When
        sut.fetchWeatherDataForCurrentLocation()

        // Then
        XCTAssertTrue(mockLocationService.requestLocationPermissionCalled, "Should call requestLocationPermission on LocationService")
    }

    func testFetchWeatherDataForDefaultLocation_CallsFetchWeatherDataWithDefaultCoords() {
        // Given
        let defaultCoords = mockLocationService.defaultLocation
        let expectedResult = TestDataFactory.createSampleWeatherResponse(locationName: "DefaultCity")
        mockNetworkService.weatherResult = .success(expectedResult)

        let expectation = self.expectation(description: "Presenter receives weather data for default location")

        mockPresenter.didFetchWeatherDataCalledAction = {
            expectation.fulfill()
        }

        // When
        sut.fetchWeatherDataForDefaultLocation()

        // Then
        waitForExpectations(timeout: 1.0) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }

            XCTAssertTrue(self.mockNetworkService.fetchWeatherDataCalled, "Should call fetchWeatherData on NetworkService")
            XCTAssertEqual(self.mockNetworkService.receivedLatitude, defaultCoords.latitude, "Should fetch with default latitude")
            XCTAssertEqual(self.mockNetworkService.receivedLongitude, defaultCoords.longitude, "Should fetch with default longitude")
            XCTAssertTrue(self.mockPresenter.didFetchWeatherDataCalled)
            XCTAssertEqual(self.mockPresenter.receivedWeatherData?.location.name, expectedResult.location.name)
        }
    }

    // MARK: - LocationServiceDelegate Callbacks -> Interactor Logic

    func testDidUpdateLocation_CallsPresenterDidUpdateLocation_AndFetchesWeather() {
        // Given
        let lat = 51.5
        let lon = -0.1
        let expectedResult = TestDataFactory.createSampleWeatherResponse(locationName: "FromDelegate")
        mockNetworkService.weatherResult = .success(expectedResult)

        let weatherDataExpectation = self.expectation(description: "Presenter receives weather data after location update")
        mockPresenter.didFetchWeatherDataCalledAction = {
            weatherDataExpectation.fulfill()
        }
        
        let locationUpdateExpectation = self.expectation(description: "Presenter is notified of location update")
        mockPresenter.didUpdateLocationCalledAction = {
            locationUpdateExpectation.fulfill()
        }


        // When
        mockLocationService.simulateLocationUpdate(lat: lat, lon: lon)

        // Then
        waitForExpectations(timeout: 1.0) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
            XCTAssertTrue(self.mockPresenter.didUpdateLocationCalled, "Presenter should be notified of location update")
            XCTAssertEqual(self.mockPresenter.receivedLatitude, lat)
            XCTAssertEqual(self.mockPresenter.receivedLongitude, lon)

            XCTAssertTrue(self.mockNetworkService.fetchWeatherDataCalled, "NetworkService fetchWeatherData should be called")
            XCTAssertEqual(self.mockNetworkService.receivedLatitude, lat)
            XCTAssertEqual(self.mockNetworkService.receivedLongitude, lon)

            XCTAssertTrue(self.mockPresenter.didFetchWeatherDataCalled)
            XCTAssertEqual(self.mockPresenter.receivedWeatherData?.location.name, "FromDelegate")
        }
    }

    func testDidFailWithError_CallsPresenterDidFailToUpdateLocation() {
        // Given
        let locationError = LocationError.locationUnknown
        
        let expectation = self.expectation(description: "Presenter is notified of location failure")
        mockPresenter.didFailToUpdateLocationCalledAction = {
            expectation.fulfill()
        }


        // When
        mockLocationService.simulateLocationError(error: locationError)

        // Then
        waitForExpectations(timeout: 1.0) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
            XCTAssertTrue(self.mockPresenter.didFailToUpdateLocationCalled, "Presenter should be notified of location failure")
            XCTAssertEqual(self.mockPresenter.receivedLocationError, locationError)
            XCTAssertFalse(self.mockNetworkService.fetchWeatherDataCalled)
        }
    }

    // MARK: - NetworkService Callbacks -> Interactor Logic

    func testFetchWeatherDataSuccess_CallsPresenterDidFetchWeatherData() {
        // Given
        let expectedData = TestDataFactory.createSampleWeatherResponse(locationName: "NetworkSuccess")
        mockNetworkService.weatherResult = .success(expectedData)

        let expectation = self.expectation(description: "Presenter receives weather data on network success")
        mockPresenter.didFetchWeatherDataCalledAction = {
            expectation.fulfill()
        }

        // When
        sut.fetchWeatherDataForDefaultLocation()

        // Then
        waitForExpectations(timeout: 1.0) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
            XCTAssertTrue(self.mockPresenter.didFetchWeatherDataCalled)
            XCTAssertEqual(self.mockPresenter.receivedWeatherData?.location.name, expectedData.location.name)
            XCTAssertFalse(self.mockPresenter.didFailToFetchWeatherDataCalled)
        }
    }

    func testFetchWeatherDataFailure_CallsPresenterDidFailToFetchWeatherData() {
        // Given
        let networkError = NetworkError.requestFailed(NSError(domain: "net", code: -1009))
        mockNetworkService.weatherResult = .failure(networkError)

        let expectation = self.expectation(description: "Presenter is notified of network failure")
        mockPresenter.didFailToFetchWeatherDataCalledAction = {
            expectation.fulfill()
        }

        // When
        sut.fetchWeatherDataForDefaultLocation()

        // Then
        waitForExpectations(timeout: 1.0) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
            XCTAssertTrue(self.mockPresenter.didFailToFetchWeatherDataCalled)
            guard case .networkError(let receivedNetErr) = self.mockPresenter.receivedWeatherError else {
                XCTFail("Expected .networkError, got \(String(describing: self.mockPresenter.receivedWeatherError))")
                return
            }
            XCTAssertEqual((receivedNetErr as NSError).code, (networkError as NSError).code)
            XCTAssertFalse(self.mockPresenter.didFetchWeatherDataCalled)
        }
    }
}
