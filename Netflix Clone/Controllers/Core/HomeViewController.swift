//
//  HomeViewController.swift
//  Netflix Clone
//
//  Created by Seyedvahid Dianat on 22/07/2022.
//

import UIKit

class HomeViewController: UIViewController {

    enum Sections: Int {
        case TrendingMovies = 0
        case TrendingTv = 1
        case Popular = 2
        case Upcoming = 3
        case Toprated = 4

    }
    
    let sectionTitles: [String] = ["Trending Movies","Trending TV","Popular","Upcoming Movies","Top Rated"]
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionTableViewCell.self, forCellReuseIdentifier: CollectionTableViewCell.identifier)
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        configureNavBar()
        let headerView =  HeroheaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        homeFeedTable.tableHeaderView = headerView
        
    }
    
    private func configureNavBar(){
        var logo = UIImage(named: "netflixLogo")
        logo = logo?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: logo, style: .done, target: self, action: nil)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
         UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)]

        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        homeFeedTable.frame = view.bounds
    }

}

extension HomeViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell.identifier, for: indexPath) as? CollectionTableViewCell else{
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies{ results in
                switch results {
                    case .success(let titles):
                    cell.configure(with: titles)

                case .failure(let error):
                    print(error.localizedDescription)

                }
            }
        case Sections.TrendingTv.rawValue:
            APICaller.shared.getTrendingTVs{ results in
                switch results {
                    case .success(let titles):
                    cell.configure(with: titles)

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }

        case Sections.Popular.rawValue:
            APICaller.shared.getPopular { results in
                        switch results {
                            case .success(let titles):
                            cell.configure(with: titles)

                        case .failure(let error):
                            print(error.localizedDescription)

                        }

            }
        case Sections.Upcoming.rawValue:
            APICaller.shared.getUpcomingMovies{ results in
                        switch results {
                            case .success(let titles):
                            cell.configure(with: titles)

                        case .failure(let error):
                            print(error.localizedDescription)

                        }

            }
        case Sections.Toprated.rawValue:
            APICaller.shared.getTopRated{ results in
                        switch results {
                            case .success(let titles):
                            cell.configure(with: titles)

                        case .failure(let error):
                            print(error.localizedDescription)
                        }
            }
        default:
            return UITableViewCell()
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionHeader = sectionTitles[section]
        return sectionHeader
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = defaultOffset + scrollView.contentOffset.y
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
        
    }
    
    
}




