//
//  CollectionTableViewCell.swift
//  Netflix Clone
//
//  Created by Seyedvahid Dianat on 22/07/2022.
//

import UIKit

protocol CollectionViewTableViewCellDelegate: AnyObject {
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionTableViewCell, viewModel: TitlePreviewViewModel)
}

class CollectionTableViewCell: UITableViewCell {
    weak var delegate: CollectionViewTableViewCellDelegate?

    static let identifier = "CollectionTableViewCell"

    private var titles: [Title] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .systemPink
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.frame = contentView.bounds
    }

    public func configure(with titles: [Title]) {
        self.titles = titles

        DispatchQueue.main.async {
            [weak self] in
            self?.collectionView.reloadData()
        }
    }

    private func downloadAtIndex(indexPath: IndexPath) {
        DataPersistenceManager.shared.downloadTitleWith(model: titles[indexPath.row]) { result in
            switch result {
            case .success:
                print("Downloaded... \(self.titles[indexPath.row].original_title ?? self.titles[indexPath.row].original_name ?? "")")
                NotificationCenter.default.post(name: Notification.Name("Downloaded"), object: nil)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else { return UICollectionViewCell() }
        guard let model = titles[indexPath.row].poster_path else { return cell }
        cell.configure(with: model)

        return cell
    }

    func collectionView(_: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point _: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in

            let downloadAction = UIAction(title: "Download", subtitle: nil, image: nil, identifier: nil, discoverabilityTitle: nil, state: .off) { _ in

                self?.downloadAtIndex(indexPath: indexPath)
            }

            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction])
        }
        return config
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        titles.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else { return }

        APICaller.shared.getMovie(with: titleName + " trailer") { [weak self] result in
            switch result {
            case let .success(videoElement):
                let title = self?.titles[indexPath.row]
                guard let titleOverview = title?.overview else { return }

                guard let strongSelf = self else { return }
                let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: titleOverview)
                self?.delegate?.collectionViewTableViewCellDidTapCell(strongSelf, viewModel: viewModel)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
