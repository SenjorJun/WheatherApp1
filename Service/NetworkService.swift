//
//  NetworkService.swift
//  WheatherApp
//
//  Created by Сергей Соловьёв on 27.02.2024.
//

import Foundation
import UIKit
import RxCocoa
import RxRelay
import RxSwift



private enum APIKey: String {
  case key = "&appid=ff7d0cabc4c3c2bd93fc04fc087f0d0e"
}
private enum Body: String {
  case units = "&units=metric"
  case limit = "&limit=1"
}
private enum Endpoints: String {
  case current = "/weather?"
  case forecast = "/forecast?"
  case city = "/direct?"
}

final class NetworkService {
  
  private var relayCurrentWeather = PublishRelay<CurrentWeather>()
  private var relayForecastWeather = PublishRelay<ForecastResponse>()
  private var relayWeatherIcon = PublishRelay<UIImage>()
  
  private let baseUrl = "https://api.openweathermap.org/data/2.5"
  private let imgUrl = "https://openweathermap.org/img/wn"
  
  private func sendRequest(_ endpoint: Endpoints, with lat: Double, and lon: Double, completion: @escaping (Data) -> (Void)) {
    guard let url = URL(string: baseUrl + endpoint.rawValue + "lat=\(lat)&lon=\(lon)" + APIKey.key.rawValue + Body.units.rawValue) else { return }
    
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, _, error in
      if error == nil,
         let data {
        completion(data)
      }
    }.resume()
  }
  private func sendRequestGeo(city: String, endpoint: Endpoints, completion: @escaping (Data) -> (Void)) {
    guard let url = URL(string: "https://api.openweathermap.org/geo/1.0" + endpoint.rawValue + "q=\(city)" + Body.limit.rawValue + APIKey.key.rawValue) else { return }
    
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, _, error in
      if error == nil,
         let data {
        completion(data)
      }
    }.resume()
  }
  private func parseData<T: Decodable>(from data: Data, in type: T.Type, completion: @escaping (T) -> (Void)) {
    if let json = try? JSONDecoder().decode(type, from: data) {
      completion(json)
    } else {
      print("Error")
    }
  }
  func getCurrentWeather(lat: Double, lon: Double) {
    sendRequest(.current, with: lat, and: lon) { [weak self] data in
      self?.parseData(from: data, in: CurrentWeather.self, completion: { weather in
        guard let icon = weather.weather?[0].icon else { return }
        self?.getIcon(with: icon)
        self?.relayCurrentWeather.accept(weather)
      })
    }
  }
  func getForecastWeather(lat: Double, lon: Double) {
      sendRequest(.forecast, with: lat, and: lon) { [weak self] data in
        self?.parseData(from: data, in: ForecastResponse.self, completion: { forecast in
            self?.relayForecastWeather.accept(forecast)
        })
      }
    }

  func getIcon(with name: String) {
    guard let url = URL(string: imgUrl + "/\(name)@4x.png") else { return }
    let req = URLRequest(url: url)
    URLSession.shared.dataTask(with: req) { data, _, error in
      if error == nil,
         let data {
        guard let weatherIcon = UIImage(data: data) else {return}
        self.relayWeatherIcon.accept(weatherIcon)
      }
    }.resume()
  }
  
  func getCityName(city: String) {
      sendRequestGeo(city: city, endpoint: .city) { [weak self] data in
        self?.parseData(from: data, in: [Town].self, completion: {towns in
          if let town = towns.first {
            self?.getCurrentWeather(lat: town.lat, lon: town.lon)
          }
        })
      }
    }
  
  func getRelayCurrent() -> PublishRelay<CurrentWeather> {
    self.relayCurrentWeather
  }
  func getRelayForecast() -> PublishRelay<ForecastResponse> {
    self.relayForecastWeather
  }
  func getRelayIcon() -> PublishRelay<UIImage> {
    self.relayWeatherIcon
  }

  func getWeather(lat: Double, lon: Double) {
    getCurrentWeather(lat: lat, lon: lon)
    getForecastWeather(lat: lat, lon: lon)
  }
  func getCity(city: String) {
    getCityName(city: city)
  }
}

