//
//  ViewController.swift
//  NewsApp
//
//  Created by Nathaniel Andrian on 15/12/22.
//

import UIKit
import RxSwift
import RxCocoa

class NewsListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    var news: [Article] = []
    
    let newsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let refreshControl = UIRefreshControl()
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupLayout()
        populateNews()
    }
    
    func setup() {
        view.backgroundColor = .white
        navigationItem.title = "News"
        newsTableView.register(NewsListTableViewCell.self, forCellReuseIdentifier: NewsListTableViewCell.identifier)
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.backgroundView = activityIndicator
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        newsTableView.refreshControl = refreshControl
        
    }
    
    @objc func refresh() {
        populateNews()
    }
    
    func setupLayout() {
        view.addSubview(newsTableView)
        
        NSLayoutConstraint.activate([
            newsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            newsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: newsTableView.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: newsTableView.bottomAnchor)
        ])
    }
    
    func populateNews() {
        news.removeAll()
        DispatchQueue.main.async {
            self.newsTableView.reloadData()
        }
        
        activityIndicator.startAnimating()
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(apiKey)")!
        let resource = Resource<ArticleList>(url: url)
    
        URLRequest.loadData(resource: resource).subscribe { [weak self] article in
            self?.news = article.articles
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                self?.newsTableView.reloadData()
            }
        } onFailure: { error in
            print(error)
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
        } onDisposed: {
            print("disposed")
        }.disposed(by: disposeBag)
        
    }
}

extension NewsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsListTableViewCell.identifier) as! NewsListTableViewCell
        cell.selectionStyle = .none
        cell.titleLabel.text = news[indexPath.row].title
        cell.descriptionLabel.text = news[indexPath.row].description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}

