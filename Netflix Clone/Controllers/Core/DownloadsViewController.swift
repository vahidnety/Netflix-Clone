//
//  DownloadsViewController.swift
//  Netflix Clone
//
//  Created by Seyedvahid Dianat on 22/07/2022.
//

import UIKit

class DownloadsViewController: UIViewController {
    private var titles: [TitleItem] = .init()
    private let downloadedTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(downloadedTable)

        view.backgroundColor = .systemBackground
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        downloadedTable.delegate = self
        downloadedTable.dataSource = self
        fetchLocalStorageForDownload()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Downloaded"), object: nil, queue: nil) { _ in
            self.fetchLocalStorageForDownload()
        }
    }

    private func fetchLocalStorageForDownload() {
        DataPersistenceManager.shared.fetchingDataFromDataBase { [weak self] result in
            switch result {
            case let .success(titleItems):
                self?.titles = titleItems
                DispatchQueue.main.async {
                    self?.downloadedTable.reloadData()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        downloadedTable.frame = view.bounds
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            DataPersistenceManager.shared.deleteTitleWith(model: titles[indexPath.row]) { [weak self] result in
                switch result {
                case .success:
                    print("Deleted successfuly!")
                case let .failure(error):
                    print(error.localizedDescription)
                }
                self?.titles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
    }
}
