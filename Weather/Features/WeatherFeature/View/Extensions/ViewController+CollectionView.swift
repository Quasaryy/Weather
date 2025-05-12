//
//  ViewController+CollectionView.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import UIKit

extension ViewController: UICollectionViewDataSource,
                          UICollectionViewDelegate,
                          UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        hourlyForecastData.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyForecastCollectionViewCell.identifier,
            for: indexPath) as? HourlyForecastCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: hourlyForecastData[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - 10
        return .init(width: 70, height: height)
    }
}
