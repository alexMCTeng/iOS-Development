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

    @IBOutlet weak var detailedImage: UIImageView!
    @IBOutlet weak var detailedTitle: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    var movie: Movie!
    var isFav: Bool!
    var movieImage: UIImage?
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var date: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        self.rating.text = String(self.movie.vote_average)
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
                favoriteBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                return
            }
        }
        self.isFav = false
        favoriteLabel.text = "Add to Favorite"
        favoriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
    }
    
    @IBAction func addToFavorite(_ sender: UIButton) {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
