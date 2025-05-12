//
//  HourlyForecastCollectionViewCell.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import UIKit
import Kingfisher

class HourlyForecastCollectionViewCell: UICollectionViewCell {
    static let identifier = "HourlyForecastCollectionViewCell"

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [timeLabel, iconImageView, temperatureLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.text = nil
        iconImageView.kf.cancelDownloadTask()
        iconImageView.image = nil
        temperatureLabel.text = nil
    }

    func configure(with viewModel: HourlyWeatherViewModel) {
        timeLabel.text = viewModel.time
        temperatureLabel.text = viewModel.temperature
        if let iconURL = viewModel.conditionIconURL {
            iconImageView.kf.setImage(
                with: iconURL,
                placeholder: UIImage(systemName: "photo"),
                options: [
                    .transition(.fade(0.2))
                ])
        }
    }
}
