import UIKit
import SnapKit
import CoreLocation
import RxSwift
import RxCocoa



//README К сожалению, не хватило времени реализовать до конца. Неверно расчитал тайминги. Прогноз погоды на несколько дней вперед реализован, но не расположен в таблице. CodeStyle применен не до конца


class WeatherViewController: UIViewController {
  
  //MARK: - let/var
  
  private let viewModel = WeatherAppViewModel()
  private let disposeBag = DisposeBag()
  let scrollView = UIScrollView()
  let contentView = UIView()
  let weatherIconImageViewShadowView = UIView()
  let backgroundImageView = UIImageView()
  let outputString = NSMutableString()
  let searchBar = UISearchBar()
  let tapGesture = UITapGestureRecognizer()
  let weatherIconImageView = UIImageView()
  let nameRect = UILabel()
  let tempRect = UILabel()
  let forecastRect = UILabel()
  let topLeftSmallSquare = UILabel()
  let topLeftSmallSquareScoreLabel = UILabel()
  let topRightSmallSquare = UILabel()
  let topRightSmallSquareScoreLabel = UILabel()
  let bottomLeftSmallSquare = UILabel()
  let bottomLeftSmallSquareScoreLabel = UILabel()
  let bottomRightSmallSquare = UILabel()
  let bottomRightSmallSquareScoreLabel = UILabel()
  var nameOfTown: String?
  var celsiusTemp: Int?
  var windSpeed: Double?
  var humidityScore: Double?
  var rainMM: Double?
  var cloudsScore: Double?
  let locationManager = CLLocationManager()
  
  
  //MARK: - lifecycle func

  override func viewDidLoad() {
    super.viewDidLoad()
    configureScreen()
  }
  
  //MARK: - flow funcs
  
  func configureScreen() {
    fetchLocation()
    createBackgroundImageView()
    view.insertSubview(backgroundImageView, at: 0)
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    scrollView.addSubview(contentView)
    scrollView.contentInsetAdjustmentBehavior = .never
    updateScreen()
    createSearchBar()
    creatWeatherIconImageViewShadowView()
    createWeatherIconImageView()
    createNameRect()
    createTempRect()
    createTopLeftSmallSquare()
    createTopRightSmallSquare()
    createBottomLeftSmallSquare()
    createBottomRightSmallSquare()
    createTapGesture()
    createForecastRect()
    contentView.snp.makeConstraints { make in
      make.edges.width.equalTo(scrollView)
      make.bottom.equalTo(forecastRect.snp.bottom).offset(Constants.offset * 5)
    }
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
  func updateScreen() {
    viewModel.service.getRelayCurrent().subscribe(onNext: { [weak self] currentWeather in
      DispatchQueue.main.async {
        self?.nameRect.text = currentWeather.name ?? "N/A"
        
        if let speedOfWind = currentWeather.wind?.speed {
          self?.topLeftSmallSquareScoreLabel.text = "\(speedOfWind)"
        } else {
          self?.topLeftSmallSquareScoreLabel.text = "N/A"
        }
        if let rainMM = currentWeather.rain?.volume {
          self?.bottomLeftSmallSquareScoreLabel.text = "\(rainMM)"
        } else {
          self?.bottomLeftSmallSquareScoreLabel.text = "N/A"
        }
        if let clouds = currentWeather.clouds?.all {
          self?.bottomRightSmallSquareScoreLabel.text = "\(clouds)"
        } else {
          self?.bottomRightSmallSquareScoreLabel.text = "N/A"
        }
        
        if let temperature = currentWeather.main?.temp {
          self?.tempRect.text = "\(Int(temperature))°С"
        } else {
          self?.tempRect.text = "N/A"
        }
        if let humidity = currentWeather.main?.humidity {
          self?.topRightSmallSquareScoreLabel.text = "\(Int(humidity))"
        } else {
          self?.topRightSmallSquareScoreLabel.text = "N/A"
        }
      }
    }).disposed(by: disposeBag)
    
    viewModel.service.getRelayIcon().subscribe(onNext: { [weak self] image in
      DispatchQueue.main.async {
        self?.weatherIconImageView.image = image
      }
    }).disposed(by: disposeBag)
    
    viewModel.service.getRelayForecast().subscribe(onNext: { [weak self] forecastresponse in
      DispatchQueue.main.async {
        let forecastString = "\(forecastresponse)"
        self?.forecastRect.text = forecastString }
    }).disposed(by: disposeBag)
  }
  
  private func createBackgroundImageView() {
    backgroundImageView.image = UIImage(named: "Background")
    backgroundImageView.frame = view.bounds
    backgroundImageView.contentMode = .scaleAspectFill
  }
  
  private func createSearchBar() {
    searchBar.placeholder = "Enter coordinates"
    searchBar.searchBarStyle = .minimal
    searchBar.layer.cornerRadius = Constants.cornerRadius
    searchBar.clipsToBounds = true
    searchBar.delegate = self
    contentView.addSubview(searchBar)
    searchBar.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(Constants.offset * 2) // Отступ от верхней границы contentView
      make.leading.equalToSuperview().offset(Constants.smallOffset)
      make.trailing.equalToSuperview().offset(-Constants.smallOffset)
    }
  }
  
  private func creatWeatherIconImageViewShadowView() {
    weatherIconImageViewShadowView.backgroundColor = .white.withAlphaComponent(Constants.alpha * 2)
    weatherIconImageViewShadowView.layer.cornerRadius = Constants.cornerRadius
    weatherIconImageViewShadowView.layer.borderWidth = 1
    weatherIconImageViewShadowView.layer.borderColor = UIColor.lightGray.cgColor
    contentView.addSubview(weatherIconImageViewShadowView)
    weatherIconImageViewShadowView.snp.makeConstraints { make in
      make.top.equalTo(searchBar.snp.bottom).offset(Constants.offset)
      make.centerX.equalToSuperview()
      make.width.equalTo(Constants.offset * 5)
      make.height.equalTo(Constants.offset * 5)
    }
  }
  
  private func createWeatherIconImageView() {
    weatherIconImageView.contentMode = .center
    contentView.addSubview(weatherIconImageView)
    weatherIconImageView.snp.makeConstraints { make in
      make.center.equalTo(weatherIconImageViewShadowView)
    }
  }
  
  private func createNameRect() {
    nameRect.backgroundColor = .white.withAlphaComponent(Constants.alpha)
    nameRect.textColor = .black
    nameRect.textAlignment = .center
    nameRect.font = .systemFont(ofSize: Constants.font)
    nameRect.text = "Weather search"
    nameRect.layer.cornerRadius = Constants.cornerRadius
    nameRect.clipsToBounds = true
    nameRect.numberOfLines = 0
    contentView.addSubview(nameRect)
    nameRect.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(weatherIconImageViewShadowView.snp.bottom).offset(Constants.offset)
      make.leading.equalToSuperview().offset(Constants.offset)
      make.trailing.equalToSuperview().offset(-Constants.offset)
    }
  }
  
  private func createTempRect() {
    tempRect.backgroundColor = .white.withAlphaComponent(Constants.alpha)
    tempRect.textColor = .black
    tempRect.textAlignment = .center
    tempRect.font = .systemFont(ofSize: Constants.font)
    tempRect.text = "°С"
    tempRect.layer.cornerRadius = Constants.cornerRadius
    tempRect.clipsToBounds = true
    tempRect.numberOfLines = 0
    contentView.addSubview(tempRect)
    tempRect.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(nameRect.snp.bottom).offset(Constants.offset)
      make.leading.equalToSuperview().offset(Constants.offset)
      make.trailing.equalToSuperview().offset(-Constants.offset)
    }
  }
  
  private func createTopLeftSmallSquare() {
    topLeftSmallSquare.backgroundColor = .white.withAlphaComponent(Constants.alpha)
    topLeftSmallSquare.textColor = .white
    topLeftSmallSquare.textAlignment = .center
    topLeftSmallSquare.layer.cornerRadius = Constants.cornerRadius
    topLeftSmallSquare.clipsToBounds = true
    topLeftSmallSquare.numberOfLines = 0
    contentView.addSubview(topLeftSmallSquare)
    topLeftSmallSquare.snp.makeConstraints { make in
      make.top.equalTo(tempRect.snp.bottom).offset(Constants.offset)
      make.leading.equalToSuperview().offset(Constants.offset)
      make.width.equalTo(Constants.screen.width/2.3)
      make.height.equalTo(Constants.screen.width/2.3)
    }
    
    let topLeftSmallSquareTextLabel = UILabel()
    topLeftSmallSquareTextLabel.text = "Wind speed"
    contentView.addSubview(topLeftSmallSquareTextLabel)
    topLeftSmallSquareTextLabel.snp.makeConstraints { make in
      make.top.equalTo(topLeftSmallSquare.snp.top).offset(Constants.smallOffset)
      make.centerX.equalTo(topLeftSmallSquare.snp.centerX)
    }
    contentView.addSubview(topLeftSmallSquareScoreLabel)
    topLeftSmallSquareScoreLabel.font = .systemFont(ofSize: Constants.font)
    topLeftSmallSquareScoreLabel.snp.makeConstraints { make in
      make.top.equalTo(topLeftSmallSquareTextLabel.snp.bottom).offset(Constants.offset)
      make.centerX.equalTo(topLeftSmallSquare.snp.centerX)
    }
  }
  
  private func createTopRightSmallSquare() {
    topRightSmallSquare.backgroundColor = .white.withAlphaComponent(Constants.alpha)
    topRightSmallSquare.textColor = .white
    topRightSmallSquare.textAlignment = .center
    topRightSmallSquare.layer.cornerRadius = Constants.cornerRadius
    topRightSmallSquare.clipsToBounds = true
    topRightSmallSquare.numberOfLines = 0
    contentView.addSubview(topRightSmallSquare)
    topRightSmallSquare.snp.makeConstraints { make in
      make.top.equalTo(tempRect.snp.bottom).offset(Constants.offset)
      make.trailing.equalToSuperview().offset(-Constants.offset)
      make.width.equalTo(Constants.screen.width/2.3)
      make.height.equalTo(Constants.screen.width/2.3)
    }
    
    let topRightSmallSquareTextLabel = UILabel()
    topRightSmallSquareTextLabel.text = "Humidity"
    contentView.addSubview(topRightSmallSquareTextLabel)
    topRightSmallSquareTextLabel.snp.makeConstraints { make in
      make.top.equalTo(topRightSmallSquare.snp.top).offset(Constants.smallOffset)
      make.centerX.equalTo(topRightSmallSquare.snp.centerX)
    }
    contentView.addSubview(topRightSmallSquareScoreLabel)
    topRightSmallSquareScoreLabel.font = .systemFont(ofSize: Constants.font)
    topRightSmallSquareScoreLabel.snp.makeConstraints { make in
      make.top.equalTo(topRightSmallSquareTextLabel.snp.bottom).offset(Constants.offset)
      make.centerX.equalTo(topRightSmallSquare.snp.centerX)
    }
  }
  
  private func createBottomLeftSmallSquare() {
    bottomLeftSmallSquare.backgroundColor = .white.withAlphaComponent(Constants.alpha)
    bottomLeftSmallSquare.textColor = .white
    bottomLeftSmallSquare.textAlignment = .center
    bottomLeftSmallSquare.layer.cornerRadius = Constants.cornerRadius
    bottomLeftSmallSquare.clipsToBounds = true
    bottomLeftSmallSquare.numberOfLines = 0
    contentView.addSubview(bottomLeftSmallSquare)
    bottomLeftSmallSquare.snp.makeConstraints { make in
      make.top.equalTo(topLeftSmallSquare.snp.bottom).offset(Constants.offset)
      make.leading.equalToSuperview().offset(Constants.offset)
      make.width.equalTo(Constants.screen.width/2.3)
      make.height.equalTo(Constants.screen.width/2.3)
    }
    
    let bottomLeftSmallSquareTextLabel = UILabel()
    bottomLeftSmallSquareTextLabel.text = "Rain"
    contentView.addSubview(bottomLeftSmallSquareTextLabel)
    bottomLeftSmallSquareTextLabel.snp.makeConstraints { make in
      make.top.equalTo(bottomLeftSmallSquare.snp.top).offset(Constants.offset)
      make.centerX.equalTo(bottomLeftSmallSquare.snp.centerX)
    }
    contentView.addSubview(bottomLeftSmallSquareScoreLabel)
    bottomLeftSmallSquareScoreLabel.font = .systemFont(ofSize: Constants.font)
    bottomLeftSmallSquareScoreLabel.snp.makeConstraints { make in
      make.top.equalTo(bottomLeftSmallSquareTextLabel.snp.bottom).offset(Constants.offset)
      make.centerX.equalTo(bottomLeftSmallSquareTextLabel.snp.centerX)
    }
  }
  
  private func createBottomRightSmallSquare() {
    bottomRightSmallSquare.backgroundColor = .white.withAlphaComponent(Constants.alpha)
    bottomRightSmallSquare.textColor = .white
    bottomRightSmallSquare.textAlignment = .center
    bottomRightSmallSquare.layer.cornerRadius = Constants.cornerRadius
    bottomRightSmallSquare.clipsToBounds = true
    bottomRightSmallSquare.numberOfLines = 0
    contentView.addSubview(bottomRightSmallSquare)
    bottomRightSmallSquare.snp.makeConstraints { make in
      make.top.equalTo(topRightSmallSquare.snp.bottom).offset(Constants.offset)
      make.trailing.equalToSuperview().offset(-Constants.offset)
      make.width.equalTo(Constants.screen.width/2.3)
      make.height.equalTo(Constants.screen.width/2.3)
    }
    
    let bottomRightSmallSquareTextLabel = UILabel()
    bottomRightSmallSquareTextLabel.text = "Clouds"
    contentView.addSubview(bottomRightSmallSquareTextLabel)
    bottomRightSmallSquareTextLabel.snp.makeConstraints { make in
      make.top.equalTo(bottomRightSmallSquare.snp.top).offset(Constants.offset)
      make.centerX.equalTo(bottomRightSmallSquare.snp.centerX)
    }
    contentView.addSubview(bottomRightSmallSquareScoreLabel)
    bottomRightSmallSquareScoreLabel.font = .systemFont(ofSize: Constants.font)
    bottomRightSmallSquareScoreLabel.snp.makeConstraints { make in
      make.top.equalTo(bottomRightSmallSquareTextLabel.snp.bottom).offset(Constants.offset)
      make.centerX.equalTo(bottomRightSmallSquare.snp.centerX)
    }
  }
  
  private func createForecastRect() {
    forecastRect.backgroundColor = .white.withAlphaComponent(Constants.alpha)
    forecastRect.textColor = .black
    forecastRect.textAlignment = .left
    forecastRect.font = .systemFont(ofSize: Constants.smallFont)
    forecastRect.text = "Loading..."
    forecastRect.layer.cornerRadius = Constants.cornerRadius
    forecastRect.clipsToBounds = true
    forecastRect.numberOfLines = 0
    contentView.addSubview(forecastRect)
    forecastRect.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(bottomLeftSmallSquare.snp.bottom).offset(Constants.offset)
      make.leading.equalToSuperview().offset(Constants.offset)
      make.trailing.equalToSuperview().offset(-Constants.offset)
    }
  }
  
  private func createTapGesture() {
    tapGesture.addTarget(self, action: #selector(hideKeyboard))
    tapGesture.cancelsTouchesInView = false
    contentView.addGestureRecognizer(tapGesture)
  }
  
  @objc func hideKeyboard() {
    view.endEditing(true)
  }
}

//MARK: - extensions

extension WeatherViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let city = searchBar.text else { return }
    viewModel.getCity(city: city)
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}

extension WeatherViewController: CLLocationManagerDelegate {
  func fetchLocation() {
    guard let location = locationManager.location else {
      return
    }
    
    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude
    viewModel.getWeather(lat: latitude, lon: longitude)
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse:
      locationManager.startUpdatingLocation()
    case .denied, .restricted:
      print("Location access denied")
    default:
      break
    }
  }
}
