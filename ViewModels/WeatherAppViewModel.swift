//
//  WheatherAppViewModel.swift
//  WheatherApp
//
//  Created by Сергей Соловьёв on 27.02.2024.
//

import Foundation
import CoreLocation

final class WeatherAppViewModel {
  let locationManager = CLLocationManager()

  var service = NetworkService()
  
  func getWeather(lat: Double, lon: Double) {
    service.getWeather(lat: lat, lon: lon)
  }
  func getCity(city: String) {
    service.getCity(city: city)
  }
}
