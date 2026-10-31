//
//  DetailedViewController.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 11/1/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

// Just like the original DetailedViewController but this one is used in Favorite tab.
import Foundation
import UIKit

class DetailedViewController_fav: UIViewController {

    private let detailView = MovieDetailView()
    private var detailedImage: UIImageView { detailView.posterView }
    private var detailedTitle: UILabel { detailView.titleLabel }
    private var favoriteLabel: UILabel { detailView.favoriteLabel }
    private var favoriteBtn: UIButton { detailView.favoriteButton }
    private var rating: UILabel { detailView.ratingLabel }
    private var overview: UILabel { detailView.overviewLabel }
    private var date: UILabel { detailView.dateLabel }

    let movie: Movie
    private let movieImage: UIImage?
    private var isFav = false

    init(movie: Movie, image: UIImage? = nil) {
        self.movie = movie
        self.movieImage = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Create movie detail controllers with init(movie:image:)")
    }

    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteBtn.addTarget(self, action: #selector(addToFavorite(_:)), for: .touchUpInside)
        setupDetailedView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "changeFavInDetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushBack), name: NSNotification.Name(rawValue: "changeSettingPushBack"), object: nil)
    }

    @objc func refresh(){
        navigationController?.popViewController(animated: true)
    }

    @objc func pushBack(){
        navigationController?.popViewController(animated: true)
    }

    func setupDetailedView(){
        self.rating.text = String(format: "%.1f", self.movie.vote_average)
        self.rating.textColor = UIColor.red
        self.overview.text = self.movie.overview
        self.date.text = self.movie.release_date
        self.detailedTitle.text = self.movie.title

        if let imageFromFav = movieImage{
            self.detailedImage.image = imageFromFav
        } else{
            let movieImage = UIImage(named: "error")
            self.detailedImage.image = movieImage
        }
        self.isInFavorite()
    }

    func isInFavorite(){
        let favoriteMovieList = UserDefaults.standard.array(forKey:"movieDB") as? [Data] ?? []
        for eachData in favoriteMovieList{
            let tempDecoded = try! NSKeyedUnarchiver.unarchivedObject(ofClass: StoredMovie.self, from: eachData)
            if tempDecoded!.title == movie.title{
                self.isFav = true
                favoriteLabel.text = "Remove"
                favoriteBtn.accessibilityLabel = "Remove from Favorite"
                favoriteBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                return
            }
        }
        self.isFav = false
        favoriteLabel.text = "Add to Favorite"
        favoriteBtn.accessibilityLabel = "Add to Favorite"
        favoriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
    }

    @objc func addToFavorite(_ sender: UIButton) {
        if isFav == false{
            let rawImageData = detailedImage.image
            let nsImageData = rawImageData!.jpegData(compressionQuality: 0.2)! as NSData
            let tempData = StoredMovie(movieId: movie.id, moviePoster: movie.poster_path, movieTitle: movie.title, movieDate: movie.release_date, movieRating: movie.vote_average, movieOverview: movie.overview, movieVote: movie.vote_count)
            let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: tempData, requiringSecureCoding: true)
            var favMovieList = UserDefaults.standard.array(forKey: "movieDB") as? [Data] ?? []
            var favMovieImageList = UserDefaults.standard.array(forKey: "movieImageDB") as? [NSData] ?? []
            favMovieList.append(encodedData)
            favMovieImageList.append(nsImageData)
            UserDefaults.standard.set(favMovieList, forKey: "movieDB")
            UserDefaults.standard.set(favMovieImageList, forKey: "movieImageDB")
            favoriteLabel.text = "Remove"
            favoriteBtn.accessibilityLabel = "Remove from Favorite"
            favoriteBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
            UserDefaults.standard.synchronize()
//            print("successfully added to favorite")
            isFav = true
        }else{
            var favMovieList = UserDefaults.standard.array(forKey: "movieDB") as? [Data] ?? []
            var favMovieImageList = UserDefaults.standard.array(forKey: "movieImageDB") as? [NSData] ?? []
            for i in 0..<favMovieList.count{
                let decoded = try! NSKeyedUnarchiver.unarchivedObject(ofClass: StoredMovie.self, from: favMovieList[i])
                if decoded?.title == movie.title{
                    favMovieList.remove(at: i)
                    favMovieImageList.remove(at: i)
                    UserDefaults.standard.set(favMovieList, forKey: "movieDB")
                    UserDefaults.standard.set(favMovieImageList, forKey: "movieImageDB")
                    isFav = false
                    favoriteLabel.text = "Add to Favorite"
                    favoriteBtn.accessibilityLabel = "Add to Favorite"
                    favoriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
//                    print("remove successfully")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFavInDetail_fav"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
                    navigationController?.popViewController(animated: true)
                    return
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFavInDetail_fav"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
    }



}


/*
 Old code:
 */

//        var favMovieList = UserDefaults.standard.array(forKey: "movieDB") as? [Movie] ?? []
//        if favMovieList.count == 0{
//            favMovieList.append(movie)
//            UserDefaults.standard.set(favMovieList, forKey: "movieDB")
//        } else{
//            for movieT in favMovieList{
//                if movieT.title == movie.title{
//                    print("already in array")
//                    return
//                }
//            }
//            favMovieList.append(movie)
//            UserDefaults.standard.set(favMovieList, forKey: "movieDB")
//            print("successful 2")
//        }


//        let directPath = NSHomeDirectory().appending("/Documents")
//        if !FileManager.default.fileExists(atPath: directPath){
//            do{
//                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directPath), withIntermediateDirectories: true, attributes: nil)
//            } catch{
//                print(error)
//            }
//        }
