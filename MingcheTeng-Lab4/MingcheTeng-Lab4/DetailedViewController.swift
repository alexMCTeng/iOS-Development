//
//  DetailedViewController.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 11/1/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//
import Foundation
import UIKit

// This swift file is used to display the detailed info of a movie.
class DetailedViewController: UIViewController {

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
    
    // Learned how to use observer https://stackoverflow.com/questions/54146841/swift-ios-how-to-update-using-observers
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupDetailedView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: Notification.Name(rawValue: "changeFavInDetail_fav"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushBack), name: Notification.Name(rawValue: "changeSettingPushBack"), object: nil)
    }
    
    @objc func refresh(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func pushBack(){
        navigationController?.popViewController(animated: true)
    }
    
    func setupDetailedView(){
        self.rating.text! = String(self.movie.vote_average)
        self.rating.textColor = UIColor.red
        self.overview.text = self.movie.overview
        self.date.text = self.movie.release_date
        self.detailedTitle.text = self.movie.title
        
        if let imageFromFav = movieImage{
            self.detailedImage.image = imageFromFav
        } else{
            if movie.poster_path != nil{
                let posterPath = movie.poster_path!
                let imagePath = URL(string: "https://image.tmdb.org/t/p/w500" + posterPath)
                let imageData = try? Data(contentsOf: imagePath!)
                let movieImage = UIImage(data: (imageData ?? UIImage(named: "error")?.jpegData(compressionQuality: 0.5))!)
                self.detailedImage.image = movieImage
            } else{
//                let imagePath = URL(string: "https://www.setra.com/hubfs/Sajni/crc_error.jpg")
//                let imageData = try! Data(contentsOf: imagePath!)
//                let movieImage = UIImage(data: imageData)
                let movieImage = UIImage(named: "error")
                self.detailedImage.image = movieImage
            }
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
    
    // Learned save data locally: https://stackoverflow.com/questions/28628225/how-to-save-local-data-in-a-swift-app
    // On piazza, head TA mentioned we can convert image to coredata then save. https://piazza.com/class/keyacd8h3denm?cid=296
    // learned how to convert, archive, and unarchived from https://stackoverflow.com/questions/29986957/save-custom-objects-into-nsuserdefaults
    // Learned how to update database and ask another view controller to reload from https://stackoverflow.com/questions/25921623/how-to-reload-tableview-from-another-view-controller-in-swift
    // and https://stackoverflow.com/questions/54146841/swift-ios-how-to-update-using-observers
    @IBAction func addToFavorite(_ sender: UIButton) {
        if isFav == false{
            let rawImageData = detailedImage.image
            // Learned how to reduce image quality from https://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi/29726675
            // in order to avoid some images are too large to store by UserDefaults
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
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFavInDetail"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
                    return
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFavInDetail"), object: nil)
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
 A class that contains all the info of a movie, except image, and is used to be stored locally.
 If this class has UIImage object, system will said it does not conform to Codable protocol.
 */
class StoredMovie: NSObject, NSCoding, Codable, NSSecureCoding{
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "movieTitle")
        coder.encode(overview, forKey: "movieOverview")
        coder.encode(vote_average, forKey: "movieRating")
        coder.encode(release_date, forKey: "movieDate")
    }
    
    init(movieId: Int, moviePoster: String?, movieTitle: String, movieDate:String, movieRating: Double, movieOverview: String, movieVote: Int!) {
        self.id = movieId
        self.poster_path = moviePoster
        self.title = movieTitle
        self.release_date = movieDate
        self.vote_average = movieRating
        self.overview = movieOverview
        self.vote_count = movieVote
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "movidId") as? Int
        poster_path = coder.decodeObject(forKey: "movieDate") as? String
        title = coder.decodeObject(forKey: "movieTitle") as? String
        overview = coder.decodeObject(forKey: "movieOverview") as? String
        vote_average = coder.decodeObject(forKey: "movieRating") as? Double
        release_date = coder.decodeObject(forKey: "movieDate") as? String
        vote_count = coder.decodeObject(forKey: "movieVote") as? Int
    }
    
    var id: Int!
    var poster_path: String?
    var title: String!
    var overview: String!
    var vote_average: Double!
    var release_date:String!
    var vote_count: Int!
    
    
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
