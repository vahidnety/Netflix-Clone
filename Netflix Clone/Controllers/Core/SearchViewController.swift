//
//  SearchViewController.swift
//  Netflix Clone
//
//  Created by Seyedvahid Dianat on 22/07/2022.
//

import UIKit

class SearchViewController: UIViewController {
    private var titles: [Title] = .init()

    private let searchTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a Movie or TV show."
        controller.searchBar.searchBarStyle = .minimal

        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always

        view.addSubview(searchTable)

        searchTable.delegate = self
        searchTable.dataSource = self

        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        fetchSearchMovies()

        searchController.searchResultsUpdater = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        searchTable.frame = view.bounds
    }

    private func fetchSearchMovies() {
        APICaller.shared.getSearchMovies { [weak self] result in

            switch result {
            case let .success(titles):
                self?.titles = titles

                DispatchQueue.main.async {
                    self?.searchTable.reloadData()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else { return UITableViewCell() }
        let title = titles[indexPath.row]

        let model = TitleViewModel(titleName: title.original_name ?? title.original_title ?? "UNKNOWN NAME", posterURL: title.poster_path ?? "")

        cell.configure(with: model)
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

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar

        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }

        resultsController.delegate = self

        APICaller.shared.search(with: query) { result in

            DispatchQueue.main.async {
                switch result {
                case let .success(titles):
                    resultsController.titles = titles
                    resultsController.searchResultsCollectionView.reloadData()

                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
