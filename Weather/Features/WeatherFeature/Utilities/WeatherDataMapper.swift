//
//  WeatherDataMapper.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation

struct WeatherDataMapper {

    // MARK: - Public API

    static func current(from current: CurrentWeather, location: Location) -> CurrentWeatherViewModel {
        CurrentWeatherViewModel(
            temperature: "\(Int(current.temp_c.rounded()))°C",
            conditionText: current.condition.text,
            conditionIconURL: URL(string: "https:\(current.condition.icon)"),
            feelsLike: "Ощущается как: \(Int(current.feelslike_c.rounded()))°C",
            windSpeed: "Ветер: \(current.wind_kph) км/ч, \(current.wind_dir)",
            humidity: "Влажность: \(current.humidity)%",
            pressure: "Давление: \(Int(current.pressure_mb)) мбар"
        )
    }

    static func hourly(from forecast: Forecast, currentDate: Date = Date()) -> [HourlyWeatherViewModel] {
        let calendar = Calendar.current
        let now = currentDate
        var result: [HourlyWeatherViewModel] = []

        if let today = forecast.forecastday.first {
            let todayHours = today.hour.filter { h in
                guard let d = DateFormatter.yyyyMMddHHmm.date(from: h.time) else { return false }
                return calendar.isDate(d, inSameDayAs: now) && d >= now
            }
            result.append(contentsOf: todayHours.map(mapHour))
        }

        if forecast.forecastday.count > 1 {
            let tomorrow = forecast.forecastday[1]
            _ = result.count
            result.append(contentsOf: tomorrow.hour.map(mapHour))
        }
        return Array(result.prefix(48))
    }

    static func daily(from days: [ForecastDay]) -> [DailyWeatherViewModel] {
        days.map { day in
            let date = DateFormatter.yyyyMMdd.date(from: day.date)
            let dayOfWeek = date.map { DateFormatter.EEEE.string(from: $0).capitalized } ?? "N/A"
            let dateStr   = date.map { DateFormatter.ddMM.string(from: $0) } ?? "N/A"

            return DailyWeatherViewModel(
                dayOfWeek: dayOfWeek,
                date: dateStr,
                minTemp: "Мин: \(Int(day.day.mintemp_c.rounded()))°C",
                maxTemp: "Макс: \(Int(day.day.maxtemp_c.rounded()))°C",
                conditionIconURL: URL(string: "https:\(day.day.condition.icon)"),
                chanceOfRain: day.day.daily_chance_of_rain > 0
                              ? "Дождь: \(day.day.daily_chance_of_rain)%"
                              : nil
            )
        }
    }
    
    private static func mapHour(_ h: HourWeather) -> HourlyWeatherViewModel {
        let time = DateFormatter.yyyyMMddHHmm.date(from: h.time)
                  .map { DateFormatter.HHmm.string(from: $0) } ?? "N/A"
        return HourlyWeatherViewModel(
            time: time,
            temperature: "\(Int(h.temp_c.rounded()))°C",
            conditionIconURL: URL(string: "https:\(h.condition.icon)")
        )
    }
}
