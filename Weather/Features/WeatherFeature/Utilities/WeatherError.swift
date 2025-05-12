//
//  WeatherError.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation

enum WeatherError: Error {
    case networkError(NetworkError)
    case locationError(LocationError)
    case dataProcessingError
    case unknown
}
