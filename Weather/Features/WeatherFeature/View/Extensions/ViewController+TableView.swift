//
//  ViewController+TableView.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import UIKit

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        dailyForecastData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DailyForecastTableViewCell.identifier,
            for: indexPath) as? DailyForecastTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: dailyForecastData[indexPath.row])
        return cell
    }
}
