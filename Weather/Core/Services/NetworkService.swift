//
//  NetworkService.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case noData
    case decodingError(Error)
    case apiError(String)
    case apiKeyNotFound
}

protocol NetworkServiceProtocol {
    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherForecastResponse, NetworkError>) -> Void)
}

class NetworkService: NetworkServiceProtocol {

    private let keychainService: KeychainServiceProtocol
    private let forecastBaseURL: String = "https://api.weatherapi.com/v1/forecast.json"

    init(keychainService: KeychainServiceProtocol) {
        self.keychainService = keychainService
    }

    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherForecastResponse, NetworkError>) -> Void) {
        guard let apiKey = keychainService.getAPIKey(), !apiKey.isEmpty else {
            completion(.failure(.apiKeyNotFound))
            return
        }

        guard var components = URLComponents(string: forecastBaseURL) else {
            completion(.failure(.invalidURL))
            return
        }

        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "days", value: "7"),
            URLQueryItem(name: "aqi", value: "no"),
            URLQueryItem(name: "alerts", value: "no")
        ]

        guard let url = components.url else {
            completion(.failure(.invalidURL))
            return
        }


        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet {
                    print("NetworkService: Error - Not connected to the internet.")
                }
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }


            if httpResponse.statusCode == 401 {
                completion(.failure(.apiError("Unauthorized (401). API Key may be invalid.")))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if let responseData = data, let errorString = String(data: responseData, encoding: .utf8) {
                    completion(.failure(.apiError("API Error (code \(httpResponse.statusCode)): \(errorString)")))
                } else {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            #if DEBUG
            if let responseString = String(data: data, encoding: .utf8) {
                print("NetworkService: Received data string:\n---\n\(responseString)\n---")
            } else {
                print("NetworkService: Could not convert received data to string.")
            }
            #endif

            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherForecastResponse.self, from: data)
                completion(.success(weatherData))
            } catch let decodingError {
                Self.logDetailedDecodingError(decodingError)
                completion(.failure(.decodingError(decodingError)))
            }
        }
        task.resume()
    }

    private static func logDetailedDecodingError(_ error: Error) {
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("[!!!] NetworkService: DecodingError - TypeMismatch: Expected '\(type)' but found different type at path '\(context.codingPath.map { $0.stringValue }.joined(separator: "."))'. Debug Description: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("[!!!] NetworkService: DecodingError - ValueNotFound: No value found for type '\(type)' at path '\(context.codingPath.map { $0.stringValue }.joined(separator: "."))'. Debug Description: \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("[!!!] NetworkService: DecodingError - KeyNotFound: Key '\(key.stringValue)' not found at path '\(context.codingPath.map { $0.stringValue }.joined(separator: "."))'. Debug Description: \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("[!!!] NetworkService: DecodingError - DataCorrupted: Data is corrupted at path '\(context.codingPath.map { $0.stringValue }.joined(separator: "."))'. Debug Description: \(context.debugDescription)")
            @unknown default:
                print("[!!!] NetworkService: DecodingError - Unknown decoding error.")
            }
        } else {
            print("[!!!] NetworkService: Error is not a DecodingError: \(error.localizedDescription)")
        }
    }
}
