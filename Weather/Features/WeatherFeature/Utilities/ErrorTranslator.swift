//
//  ErrorTranslator.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import Foundation

struct ErrorTranslator {

    static func message(for error: WeatherError) -> String {
        switch error {
        case .networkError(let netErr):
            switch netErr {
            case .invalidURL:
                return "Ошибка: Неверный URL для запроса погоды."
            case .requestFailed(let underlyingNetworkError):
                let nsError = underlyingNetworkError as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet {
                    return "Ошибка сети: Нет подключения к интернету."
                }
                return "Ошибка сети: Не удалось выполнить запрос (\(nsError.localizedDescription))."
            case .invalidResponse:
                return "Ошибка сети: Получен неверный ответ от сервера."
            case .noData:
                return "Ошибка сети: Сервер не вернул данных."
            case .decodingError:
                return "Ошибка: Не удалось обработать данные о погоде."
            case .apiError(let msg):
                if msg.contains("Unauthorized (401)") {
                    return "Ошибка API (401): Неверный ключ API. Попробуйте перезапустить приложение или обратитесь в поддержку."
                } else if msg.contains("API Error (code 502)") {
                    return "Ошибка сети (502): Сервер погоды временно недоступен. Попробуйте позже."
                } else {
                    return "Ошибка API: \(msg)"
                }
            case .apiKeyNotFound:
                return "Критическая ошибка: Ключ API не найден. Пожалуйста, перезапустите приложение."
            }
        case .locationError(let locErr):
            switch locErr {
            case .authorizationDenied:
                return "Доступ к геопозиции запрещён. Показываем погоду для Москвы. Вы можете поменять это в настройках."
            case .authorizationRestricted:
                return "Доступ к геопозиции ограничен. Показываем погоду для Москвы."
            case .locationUnknown:
                return "Не удалось определить ваше местоположение. Показываем погоду для Москвы."
            case .serviceDisabled:
                return "Службы геолокации выключены. Показываем погоду для Москвы. Включите их в настройках."
            case .coreLocationError:
                return "Ошибка службы геолокации. Показываем погоду для Москвы."
            }
        case .dataProcessingError:
            return "Ошибка: Не удалось обработать полученные данные."
        case .unknown:
            return "Произошла неизвестная ошибка."
        }
    }
}
