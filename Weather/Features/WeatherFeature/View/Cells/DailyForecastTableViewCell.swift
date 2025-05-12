//
//  DailyForecastTableViewCell.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import UIKit
import Kingfisher

class DailyForecastTableViewCell: UITableViewCell {
    static let identifier = "DailyForecastTableViewCell"

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let tempRangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chanceOfRainLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightText
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none

        let dayDateStack = UIStackView(arrangedSubviews: [dayLabel, dateLabel])
        dayDateStack.axis = .vertical
        dayDateStack.alignment = .leading
        dayDateStack.spacing = 2
        dayDateStack.translatesAutoresizingMaskIntoConstraints = false

        let tempRainStack = UIStackView(arrangedSubviews: [tempRangeLabel, chanceOfRainLabel])
        tempRainStack.axis = .vertical
        tempRainStack.alignment = .trailing
        tempRainStack.spacing = 2
        tempRainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(dayDateStack)
        contentView.addSubview(iconImageView)
        contentView.addSubview(tempRainStack)

        NSLayoutConstraint.activate([
            dayDateStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dayDateStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayDateStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: dayDateStack.trailingAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 45),
            iconImageView.heightAnchor.constraint(equalToConstant: 45),

            tempRainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tempRainStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tempRainStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            tempRainStack.widthAnchor.constraint(greaterThanOrEqualTo: contentView.widthAnchor, multiplier: 0.35)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = nil
        dateLabel.text = nil
        iconImageView.kf.cancelDownloadTask()
        iconImageView.image = nil
        tempRangeLabel.text = nil
        chanceOfRainLabel.text = nil
    }

    func configure(with viewModel: DailyWeatherViewModel) {
        dayLabel.text = viewModel.dayOfWeek
        dateLabel.text = viewModel.date
        tempRangeLabel.text = "\(viewModel.minTemp) / \(viewModel.maxTemp)"
        
        if let chanceOfRain = viewModel.chanceOfRain {
            chanceOfRainLabel.text = chanceOfRain
            chanceOfRainLabel.isHidden = false
        } else {
            chanceOfRainLabel.isHidden = true
        }
        
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
