//
//  ViewController.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import UIKit
import Kingfisher
import CoreLocation

private enum Constants {
    static let padding: CGFloat = 20.0
    static let spacing: CGFloat = 8.0
    static let sectionSpacing: CGFloat = 30.0
    static let cornerRadius: CGFloat = 10.0

    static let locationFontSize: CGFloat = 28.0
    static let temperatureFontSize: CGFloat = 72.0
    static let conditionFontSize: CGFloat = 20.0
    static let detailsFontSize: CGFloat = 16.0
    static let sectionTitleFontSize: CGFloat = 20.0

    static let conditionIconSize: CGFloat = 60.0
    static let hourlyCollectionHeight: CGFloat = 120.0
    static let dailyTableRowHeight: CGFloat = 80.0
    static let minDailyTableHeight: CGFloat = 200.0
}

class ViewController: UIViewController, WeatherViewProtocol, UIScrollViewDelegate {

    var presenter: WeatherPresenterProtocol?

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let locationLabel = UILabel()
    private let currentTemperatureLabel = UILabel()
    private let currentConditionLabel = UILabel()
    private let currentConditionIconImageView = UIImageView()
    private let currentFeelsLikeLabel = UILabel()
    private let currentWindLabel = UILabel()
    private let currentHumidityLabel = UILabel()
    private let currentPressureLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private lazy var currentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            locationLabel,
            currentTemperatureLabel,
            currentConditionIconImageView,
            currentConditionLabel,
            currentFeelsLikeLabel,
            currentWindLabel,
            currentHumidityLabel,
            currentPressureLabel
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Constants.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()


    private let hourlyForecastLabel = UILabel()
    private lazy var hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.padding, bottom: 0, right: Constants.padding)
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let dailyForecastLabel = UILabel()
    private lazy var dailyTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = Constants.dailyTableRowHeight
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    var hourlyForecastData: [HourlyWeatherViewModel] = []
    var dailyForecastData: [DailyWeatherViewModel] = []
    private var dailyTableViewHeightConstraint: NSLayoutConstraint?

    private var navTitleIsShown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)
        scrollView.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = false
        setupScrollView()
        setupCommonUI()
        setupCurrentWeatherSection()
        setupHourlyForecastSection()
        setupDailyForecastSection()
        setupConstraints()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.2,
                                             green: 0.6,
                                             blue: 0.8,
                                             alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance  = appearance
        navigationController?.navigationBar.isTranslucent = false
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupCommonUI() {
         activityIndicator.translatesAutoresizingMaskIntoConstraints = false
         activityIndicator.color = .white
         view.addSubview(activityIndicator)
    }

    private func setupCurrentWeatherSection() {
        configureLabel(locationLabel, size: Constants.locationFontSize, weight: .bold)
        configureLabel(currentTemperatureLabel, size: Constants.temperatureFontSize, weight: .thin)
        configureLabel(currentConditionLabel, size: Constants.conditionFontSize, weight: .medium)
        currentConditionIconImageView.translatesAutoresizingMaskIntoConstraints = false
        currentConditionIconImageView.contentMode = .scaleAspectFit

        configureLabel(currentFeelsLikeLabel, size: Constants.detailsFontSize)
        configureLabel(currentWindLabel, size: Constants.detailsFontSize)
        configureLabel(currentHumidityLabel, size: Constants.detailsFontSize)
        configureLabel(currentPressureLabel, size: Constants.detailsFontSize)

        contentView.addSubview(currentStackView)
    }

    private func setupHourlyForecastSection() {
        hourlyForecastLabel.text = "Почасовой прогноз"
        configureLabel(hourlyForecastLabel, size: Constants.sectionTitleFontSize, weight: .semibold, alignment: .left)
        contentView.addSubview(hourlyForecastLabel)

        hourlyCollectionView.delegate = self
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.register(HourlyForecastCollectionViewCell.self, forCellWithReuseIdentifier: HourlyForecastCollectionViewCell.identifier)
        contentView.addSubview(hourlyCollectionView)
    }

    private func setupDailyForecastSection() {
        dailyForecastLabel.text = "Прогноз на 7 дней"
        configureLabel(dailyForecastLabel, size: Constants.sectionTitleFontSize, weight: .semibold, alignment: .left)
        contentView.addSubview(dailyForecastLabel)
        
        dailyTableView.delegate = self
        dailyTableView.dataSource = self
        dailyTableView.register(DailyForecastTableViewCell.self, forCellReuseIdentifier: DailyForecastTableViewCell.identifier)
        contentView.addSubview(dailyTableView)

        dailyTableViewHeightConstraint = dailyTableView.heightAnchor.constraint(equalToConstant: Constants.minDailyTableHeight)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            currentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            currentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            currentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),

            currentConditionIconImageView.heightAnchor.constraint(equalToConstant: Constants.conditionIconSize),
            currentConditionIconImageView.widthAnchor.constraint(equalToConstant: Constants.conditionIconSize),

            hourlyForecastLabel.topAnchor.constraint(equalTo: currentStackView.bottomAnchor, constant: Constants.sectionSpacing),
            hourlyForecastLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            hourlyForecastLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),

            hourlyCollectionView.topAnchor.constraint(equalTo: hourlyForecastLabel.bottomAnchor, constant: Constants.spacing),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: Constants.hourlyCollectionHeight),

            dailyForecastLabel.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: Constants.sectionSpacing),
            dailyForecastLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            dailyForecastLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),

            dailyTableView.topAnchor.constraint(equalTo: dailyForecastLabel.bottomAnchor, constant: Constants.spacing),
            dailyTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dailyTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dailyTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding)
        ])

        dailyTableViewHeightConstraint?.isActive = true
        
        setWeatherElementsHidden(true)
    }


    private func configureLabel(_ label: UILabel, size: CGFloat, weight: UIFont.Weight = .regular, alignment: NSTextAlignment = .center, color: UIColor = .white) {
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textAlignment = alignment
        label.textColor = color
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setWeatherElementsHidden(_ isHidden: Bool) {
        currentStackView.isHidden = isHidden
        hourlyForecastLabel.isHidden = isHidden
        hourlyCollectionView.isHidden = isHidden
        dailyForecastLabel.isHidden = isHidden
        dailyTableView.isHidden = isHidden
    }

    func showLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.setWeatherElementsHidden(true)
            self.scrollView.isHidden = true
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
             self.scrollView.isHidden = false
        }
    }

    func displayWeather(currentWeather: CurrentWeatherViewModel, hourlyForecast: [HourlyWeatherViewModel], dailyForecast: [DailyWeatherViewModel], locationName: String) {
        DispatchQueue.main.async {
            self.setWeatherElementsHidden(false)

            self.locationLabel.text = locationName
            self.currentTemperatureLabel.text = currentWeather.temperature
            self.currentConditionLabel.text = currentWeather.conditionText
            if let iconURL = currentWeather.conditionIconURL {
                self.currentConditionIconImageView.kf.setImage(
                    with: iconURL,
                    placeholder: UIImage(systemName: "photo"),
                    options: [.transition(.fade(0.2))]
                )
            } else {
                 self.currentConditionIconImageView.image = nil
            }
            self.currentFeelsLikeLabel.text = currentWeather.feelsLike
            self.currentWindLabel.text = currentWeather.windSpeed
            self.currentHumidityLabel.text = currentWeather.humidity
            self.currentPressureLabel.text = currentWeather.pressure

            self.hourlyForecastData = hourlyForecast
            self.hourlyCollectionView.reloadData()
            self.hourlyCollectionView.setContentOffset(.zero, animated: false)

            self.dailyForecastData = dailyForecast
            self.dailyTableView.reloadData()
            
            let numberOfRows = self.dailyForecastData.count
            let newTableHeight = CGFloat(numberOfRows) * Constants.dailyTableRowHeight
            self.dailyTableViewHeightConstraint?.constant = numberOfRows == 0 ? 0 : newTableHeight
            self.dailyTableView.isScrollEnabled = false
            
            
            self.view.layoutIfNeeded()
        }
    }

    func showError(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.scrollView.isHidden = true

            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)

            let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                self?.presenter?.didTapRetry()
            }

            alert.addAction(retryAction)

            if let presentedVC = self.presentedViewController {
                 presentedVC.dismiss(animated: false) { [weak self] in
                      self?.present(alert, animated: true)
                 }
            } else {
                 self.present(alert, animated: true)
            }
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
         if !dailyForecastData.isEmpty {
         }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let labelFrame = locationLabel.superview?.convert(locationLabel.frame, to: nil),
              let navBarFrame = navigationController?.navigationBar.frame
        else { return }
        
        let contentOffsetY = scrollView.contentOffset.y
        
        if contentOffsetY > 0 && labelFrame.maxY <= navBarFrame.maxY && !navTitleIsShown {
            navigationItem.title = locationLabel.text
            navTitleIsShown = true
        }
        else if (contentOffsetY <= 0 || labelFrame.maxY > navBarFrame.maxY) && navTitleIsShown {
            navigationItem.title = nil
            navTitleIsShown = false
        }
    }
}
