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
        
        let currentHour = calendar.component(.hour, from: now)
        
        guard forecast.forecastday.count >= 2 else { return [] }
        
        let today = forecast.forecastday[0]
        let tomorrow = forecast.forecastday[1]
        
        let todayHours = today.hour.filter { hourData in
            guard let hourDate = DateFormatter.yyyyMMddHHmm.date(from: hourData.time) else { return false }
            let hour = calendar.component(.hour, from: hourDate)
            return hour >= currentHour
        }
        result.append(contentsOf: todayHours.map(mapHour))
        
        let tomorrowHours = tomorrow.hour
        result.append(contentsOf: tomorrowHours.map(mapHour))
        
        return result
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
