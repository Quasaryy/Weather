//
//  WeatherDataMapperTests.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import XCTest
@testable import Weather

class WeatherDataMapperTests: XCTestCase {

    func testCurrentMapping() {
        // Given
        let response = TestDataFactory.createSampleWeatherResponse(
            tempC: 21.3,
            conditionText: "Partly cloudy",
            icon: "//cdn.test.com/icon.png",
            feelsLikeC: 19.8,
            windKph: 15.5,
            windDir: "NW",
            humidity: 65,
            pressureMb: 1005.0
        )

        // When
        let viewModel = WeatherDataMapper.current(from: response.current, location: response.location)

        // Then
        XCTAssertEqual(viewModel.temperature, "21°C")
        XCTAssertEqual(viewModel.conditionText, "Partly cloudy")
        XCTAssertEqual(viewModel.conditionIconURL, URL(string: "https://cdn.test.com/icon.png"))
        XCTAssertEqual(viewModel.feelsLike, "Ощущается как: 20°C")
        XCTAssertEqual(viewModel.windSpeed, "Ветер: 15.5 км/ч, NW")
        XCTAssertEqual(viewModel.humidity, "Влажность: 65%")
        XCTAssertEqual(viewModel.pressure, "Давление: 1005 мбар")
    }

    func testHourlyMapping_FiltersPastHoursAndMapsCorrectly() {
        // Given
        let response = TestDataFactory.createSampleWeatherResponse(hourlyForecastCount: 24*2)

        guard let firstDay = response.forecast.forecastday.first, firstDay.hour.count >= 3 else {
            XCTFail("Test data generation failed or missing sufficient hourly data for the first day")
            return
        }
        
        let nowEpoch = firstDay.hour[2].time_epoch
        let nowDate = Date(timeIntervalSince1970: TimeInterval(nowEpoch))

        // When
        let viewModels = WeatherDataMapper.hourly(from: response.forecast, currentDate: nowDate)

        // Then
        XCTAssertFalse(viewModels.isEmpty, "ViewModels should not be empty")

        guard let firstExpectedHourModel = firstDay.hour.first(where: { $0.time_epoch == nowEpoch }) else {
            XCTFail("Could not find the expected hour model in test data for 'nowEpoch'")
            return
        }
        
        guard let firstViewModel = viewModels.first else {
            XCTFail("View models array is empty after mapping.")
            return
        }

        let expectedTime = DateFormatter.testable_HHmm().string(from: nowDate)
        XCTAssertEqual(firstViewModel.time, expectedTime, "Time of the first ViewModel should match the 'now' time.")
        XCTAssertEqual(firstViewModel.temperature, "\(Int(firstExpectedHourModel.temp_c.rounded()))°C", "Temperature should match.")
        XCTAssertEqual(firstViewModel.conditionIconURL, URL(string: "https:\(firstExpectedHourModel.condition.icon)"), "Icon URL should match.")

        let hoursOnFirstDayFromNow = firstDay.hour.filter { $0.time_epoch >= nowEpoch }.count
        var expectedTotalHours = hoursOnFirstDayFromNow
        if response.forecast.forecastday.count > 1 {
            expectedTotalHours += response.forecast.forecastday[1].hour.count
        }
        expectedTotalHours = min(expectedTotalHours, 48)

        XCTAssertEqual(viewModels.count, expectedTotalHours, "Total number of mapped view models should be correct.")
    }

    func testDailyMapping() {
        // Given
        let response = TestDataFactory.createSampleWeatherResponse(dailyForecastCount: 3)
        guard response.forecast.forecastday.count == 3 else {
            XCTFail("Incorrect number of daily forecasts generated")
            return
        }
        let firstDayData = response.forecast.forecastday[0]
        let secondDayData = response.forecast.forecastday[1]

        // When
        let viewModels = WeatherDataMapper.daily(from: response.forecast.forecastday)

        // Then
        XCTAssertEqual(viewModels.count, 3)

        let date1 = DateFormatter.testable_yyyyMMdd().date(from: firstDayData.date)!
        XCTAssertEqual(viewModels[0].dayOfWeek, DateFormatter.testable_EEEE().string(from: date1).capitalized)
        XCTAssertEqual(viewModels[0].date, DateFormatter.testable_ddMM().string(from: date1))
        XCTAssertEqual(viewModels[0].minTemp, "Мин: \(Int(firstDayData.day.mintemp_c.rounded()))°C")
        XCTAssertEqual(viewModels[0].maxTemp, "Макс: \(Int(firstDayData.day.maxtemp_c.rounded()))°C")
        XCTAssertEqual(viewModels[0].conditionIconURL, URL(string: "https:\(firstDayData.day.condition.icon)"))
        XCTAssertEqual(viewModels[0].chanceOfRain, nil)

        let date2 = DateFormatter.testable_yyyyMMdd().date(from: secondDayData.date)!
        XCTAssertEqual(viewModels[1].dayOfWeek, DateFormatter.testable_EEEE().string(from: date2).capitalized)
        XCTAssertEqual(viewModels[1].date, DateFormatter.testable_ddMM().string(from: date2))
        XCTAssertEqual(viewModels[1].minTemp, "Мин: \(Int(secondDayData.day.mintemp_c.rounded()))°C")
        XCTAssertEqual(viewModels[1].maxTemp, "Макс: \(Int(secondDayData.day.maxtemp_c.rounded()))°C")
        XCTAssertEqual(viewModels[1].chanceOfRain, "Дождь: \(secondDayData.day.daily_chance_of_rain)%")
    }
}
