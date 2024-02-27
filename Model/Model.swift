//
//  Model.swift
//  WheatherApp
//
//  Created by Сергей Соловьёв on 25.02.2024.
//

import Foundation

struct DailyWeatherForecast {
    let date: Date
    let forecastAtNoon: Forecast
}

struct ForecastResponse: Codable {
  let list: [Forecast]
}

struct Forecast: Codable {
  let dt_txt: String
  let main: Main
  let weather: [Weather]
}

struct Main: Codable {
  let temp: Double
  let humidity: Double
}

struct Wind: Codable {
  let speed: Double
}

struct Rain: Codable {
    let volume: Double?

    enum CodingKeys: String, CodingKey {
        case volume = "3h"
    }
}

struct Clouds: Codable {
  let all: Double
}

struct Weather: Codable {
  let description: String
  let icon: String
}

struct WeatherForecast: Decodable {
  let date: String
  let temperature: Double
  let weatherDescription: String
}

struct CurrentWeather: Decodable {
  let name: String?
  let visibility: Int?
  let wind: Wind?
  let rain: Rain?
  let clouds: Clouds?
  let weather: [Weather]?
  let main: Main?
}
