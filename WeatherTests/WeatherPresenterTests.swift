//
//  WeatherPresenterTests.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import XCTest
@testable import Weather

class WeatherPresenterTests: XCTestCase {

    var sut: WeatherPresenter!
    var mockView: MockWeatherView!
    var mockInteractor: MockWeatherInteractor!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockView = MockWeatherView()
        mockInteractor = MockWeatherInteractor()
        sut = WeatherPresenter()
        sut.view = mockView
        sut.interactor = mockInteractor
    }

    override func tearDownWithError() throws {
        sut = nil
        mockView = nil
        mockInteractor = nil
        try super.tearDownWithError()
    }

    // MARK: - View -> Presenter

    func testViewDidLoad_CallsShowLoadingAndViewDidLoadOnInteractor() {
        // When
        sut.viewDidLoad()

        // Then
        XCTAssertTrue(mockView.showLoadingCalled, "viewDidLoad should call showLoading on the view")
        XCTAssertTrue(mockInteractor.fetchWeatherDataForCurrentLocationCalled, "viewDidLoad should call fetchWeatherDataForCurrentLocation on the interactor")
    }

    func testDidTapRetry_CallsShowLoadingAndFetchDataOnInteractor() {
        // When
        sut.didTapRetry()

        // Then
        XCTAssertTrue(mockView.showLoadingCalled, "didTapRetry should call showLoading on the view")
        XCTAssertTrue(mockInteractor.fetchWeatherDataForCurrentLocationCalled, "didTapRetry should call fetchWeatherDataForCurrentLocation on the interactor")
    }

    // MARK: - Interactor -> Presenter Callbacks

    func testDidFetchWeatherData_CallsHideLoadingAndDisplayWeather() {
        // Given
        let testData = TestDataFactory.createSampleWeatherResponse(locationName: "London")
        
        let expectation = self.expectation(description: "Display weather called")
        mockView.displayWeatherCalledAction = {
            expectation.fulfill()
        }


        // When
        sut.didFetchWeatherData(testData)

        // Then
        waitForExpectations(timeout: 1.0) { error in
            if let error = error { XCTFail("Timeout: \(error.localizedDescription)") }
            XCTAssertTrue(self.mockView.hideLoadingCalled, "didFetchWeatherData should call hideLoading")
            XCTAssertTrue(self.mockView.displayWeatherCalled, "didFetchWeatherData should call displayWeather")
            XCTAssertEqual(self.mockView.receivedLocationName, "London", "displayWeather should be called with correct location name")
            XCTAssertNotNil(self.mockView.receivedCurrentWeather, "displayWeather should receive current weather view model")
            XCTAssertNotNil(self.mockView.receivedHourlyForecast, "displayWeather should receive hourly forecast view models")
            XCTAssertNotNil(self.mockView.receivedDailyForecast, "displayWeather should receive daily forecast view models")
        }
    }

    func testDidFailToFetchWeatherData_CallsHideLoadingAndShowError() {
        // Given
        let testError = WeatherError.networkError(.requestFailed(NSError(domain: "test", code: 1)))
        let expectedMessage = ErrorTranslator.message(for: testError)
        
        let expectation = self.expectation(description: "Show error called")
        mockView.showErrorCalledAction = {
            expectation.fulfill()
        }

        // When
        sut.didFailToFetchWeatherData(testError)

        // Then
        waitForExpectations(timeout: 1.0) { error in
            if let error = error { XCTFail("Timeout: \(error.localizedDescription)") }
            XCTAssertTrue(self.mockView.hideLoadingCalled, "didFailToFetchWeatherData should call hideLoading")
            XCTAssertTrue(self.mockView.showErrorCalled, "didFailToFetchWeatherData should call showError")
            XCTAssertEqual(self.mockView.receivedErrorMessage, expectedMessage, "showError should be called with the translated error message")
        }
    }

    func testDidUpdateLocation_LogsMessage() {
        // Given
        let lat = 51.5
        let lon = -0.1

        // When
        sut.didUpdateLocation(latitude: lat, longitude: lon)

        // Then
        XCTAssertTrue(true) // Placeholder
    }

     func testDidFailToUpdateLocation_CallsShowLoading_CallsFetchDefaultLocation_AndSimulatesSubsequentError() {
         // Given
         let testLocationError = LocationError.locationUnknown
        
        let showErrorExpectation = self.expectation(description: "Show error after default fetch failure")
        mockView.showErrorCalledAction = {
            showErrorExpectation.fulfill()
        }
        
        var showLoadingCalledFirstTime = false
        mockView.showLoadingCalledAction = {
            if !self.mockInteractor.fetchWeatherDataForDefaultLocationCalled {
                showLoadingCalledFirstTime = true
            }
        }


         // When
         sut.didFailToUpdateLocation(testLocationError)

         // Then
         XCTAssertTrue(showLoadingCalledFirstTime, "didFailToUpdateLocation should call showLoading on view initially")
         XCTAssertTrue(mockInteractor.fetchWeatherDataForDefaultLocationCalled, "didFailToUpdateLocation should trigger fetchWeatherDataForDefaultLocation on interactor")

         let networkFetchError = WeatherError.networkError(.invalidURL)
         let finalExpectedMessage = ErrorTranslator.message(for: networkFetchError)
         sut.didFailToFetchWeatherData(networkFetchError)

         waitForExpectations(timeout: 1.0) { error in
             if let error = error { XCTFail("Timeout: \(error.localizedDescription)")}
             XCTAssertTrue(self.mockView.hideLoadingCalled)
             XCTAssertTrue(self.mockView.showErrorCalled)
             XCTAssertEqual(self.mockView.receivedErrorMessage, finalExpectedMessage)
         }
    }
}
