//
//  FavoriteViewController.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 11/1/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

import UIKit
import SystemConfiguration

// This swift file is largely learned from lecture videos Lecture 10, a lab 4 demo, and lecture 7, how to use table view.
class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .plain)
    var favoriteList:[StoredMovie] = []
    var favoriteImageList:[UIImage] = []
    var movieList:[Movie] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fav", for: indexPath)
        cell.textLabel?.text = favoriteList[indexPath.row].title
        return cell
    }

    func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "fav")
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Favorite Movies"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        setupTableView()
        getDataFromDB()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
//        print("fav loaded")
    }

    @objc func refresh() {

        self.getDataFromDB() // a refresh the tableView.

    }

    func getDataFromDB(){
        let queryMovie = UserDefaults.standard.array(forKey: "movieDB") as? [Data] ?? []
        let queryImage = UserDefaults.standard.array(forKey: "movieImageDB") as? [NSData]  ?? []
        favoriteList = []
        favoriteImageList = []
        movieList = []
        for i in 0..<queryMovie.count{
            let decodedMovie = try! NSKeyedUnarchiver.unarchivedObject(ofClass: StoredMovie.self, from: queryMovie[i])
            let decodedImage = UIImage(data: queryImage[i] as Data)
            favoriteList.append(decodedMovie!)
            favoriteImageList.append(decodedImage!)
            let movieTemp = Movie(id: decodedMovie?.id, poster_path: decodedMovie?.poster_path, title: (decodedMovie?.title)!, release_date: (decodedMovie?.release_date)!, vote_average: (decodedMovie?.vote_average)!, overview: (decodedMovie?.overview)!, vote_count: decodedMovie?.vote_count)
            movieList.append(movieTemp)
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = DetailedViewController_fav(movie: movieList[indexPath.row],
                                                image: favoriteImageList[indexPath.row])
        navigationController?.pushViewController(detail, animated: true)
    }
}
