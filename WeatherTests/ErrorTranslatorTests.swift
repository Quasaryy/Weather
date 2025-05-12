//
//  ErrorTranslatorTests.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import XCTest
@testable import Weather

class ErrorTranslatorTests: XCTestCase {

    func testNetworkErrorTranslation() {
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.invalidURL)), "Ошибка: Неверный URL для запроса погоды.")
        let noConnectionError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.requestFailed(noConnectionError))), "Ошибка сети: Нет подключения к интернету.")
        let genericError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Generic Fail"])
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.requestFailed(genericError))), "Ошибка сети: Не удалось выполнить запрос (Generic Fail).")
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.invalidResponse)), "Ошибка сети: Получен неверный ответ от сервера.")
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.noData)), "Ошибка сети: Сервер не вернул данных.")
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.decodingError(NSError(domain: "", code: 0)))), "Ошибка: Не удалось обработать данные о погоде.")
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.apiError("Unauthorized (401)"))), "Ошибка API (401): Неверный ключ API. Попробуйте перезапустить приложение или обратитесь в поддержку.")
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.apiError("API Error (code 502)"))), "Ошибка сети (502): Сервер погоды временно недоступен. Попробуйте позже.")
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.apiError("Some other API error"))), "Ошибка API: Some other API error")
        XCTAssertEqual(ErrorTranslator.message(for: .networkError(.apiKeyNotFound)), "Критическая ошибка: Ключ API не найден. Пожалуйста, перезапустите приложение.")
    }

    func testLocationErrorTranslation() {
        XCTAssertEqual(ErrorTranslator.message(for: .locationError(.authorizationDenied)), "Доступ к геопозиции запрещён. Показываем погоду для Москвы. Вы можете поменять это в настройках.")
        XCTAssertEqual(ErrorTranslator.message(for: .locationError(.authorizationRestricted)), "Доступ к геопозиции ограничен. Показываем погоду для Москвы.")
        XCTAssertEqual(ErrorTranslator.message(for: .locationError(.locationUnknown)), "Не удалось определить ваше местоположение. Показываем погоду для Москвы.")
        XCTAssertEqual(ErrorTranslator.message(for: .locationError(.serviceDisabled)), "Службы геолокации выключены. Показываем погоду для Москвы. Включите их в настройках.")
        let sampleCoreLocationError = NSError(domain: "TestCLErrorDomain", code: 1, userInfo: nil)
        XCTAssertEqual(ErrorTranslator.message(for: .locationError(.coreLocationError(sampleCoreLocationError))), "Ошибка службы геолокации. Показываем погоду для Москвы.")
    }

    func testOtherErrorTranslation() {
         XCTAssertEqual(ErrorTranslator.message(for: .dataProcessingError), "Ошибка: Не удалось обработать полученные данные.")
         XCTAssertEqual(ErrorTranslator.message(for: .unknown), "Произошла неизвестная ошибка.")
    }
}
