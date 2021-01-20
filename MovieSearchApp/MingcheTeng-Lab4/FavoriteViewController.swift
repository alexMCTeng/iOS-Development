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
    
    @IBOutlet weak var tableView: UITableView!
    var favoriteList:[StoredMovie] = []
    var favoriteImageList:[UIImage] = []
    var movieList:[Movie] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "fav")
        cell.textLabel?.text = favoriteList[indexPath.row].title
        return cell
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getDataFromDB()
        setupTableView()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favToDetailed"{
            let detailedVC = segue.destination as! DetailedViewController_fav
            detailedVC.movie = movieList[sender as! Int]
            detailedVC.movieImage = favoriteImageList[sender as! Int]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "favToDetailed", sender: indexPath.row)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
