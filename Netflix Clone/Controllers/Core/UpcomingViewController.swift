//
//  UpcomingViewController.swift
//  Netflix Clone
//
//  Created by Seyedvahid Dianat on 22/07/2022.
//

import UIKit

class UpcomingViewController: UIViewController {
    private var titles: [Title] = .init()

    private let upcomingTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white

        view.addSubview(upcomingTable)
        upcomingTable.delegate = self
        upcomingTable.dataSource = self

        fetchUpcoming()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTable.frame = view.bounds
    }

    // use [weak self] to avoid any memory leaks
    private func fetchUpcoming() {
        APICaller.shared.getUpcomingMovies {
            [weak self] result in
            switch result {
            case let .success(titles):
                self?.titles = titles

                // we put reloaddata inside the async function so that we make sure it will be executed in main thread.
                DispatchQueue.main.async {
                    self?.upcomingTable.reloadData()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension UpcomingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else { return UITableViewCell() }

        let title = titles[indexPath.row]

        cell.configure(with: TitleViewModel(titleName: title.original_title ?? title.original_name ?? "UNKNOWN NAME", posterURL: title.poster_path ?? ""))
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        140
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let title = titles[indexPath.row]

        guard let titleName = title.original_title ?? title.original_name, let overView = title.overview else {
            return
        }

        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case let .success(videoElement):
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: overView))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }

            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
