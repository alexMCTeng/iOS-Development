//
//  ViewController.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 10/22/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//

/*
 Things to do:
 1. create tab bar for viewController allowing user travel between main page, exhausted movie list, and etc(have not made my mind yet), 10/22 working on it.
 2. link to the TMDb. Created TMDB account on 10/23.
 3. Additional, create cellVC, FavoriteVC, done on 11/2
 Complete MainpageCollectionViewCell. 10/27
 */


/*
 Creative ideas:
 10/22, If we can know whether a movie's rating, then we can add a setting that enable/disable the adult content movie or not. done on 11/3
 10/28. Language options, done on 11/3
 10/28 store everything in local for favourite movie (suggested on piazza) done 11/4
 */

/*
 Attended TA hours:
 10/27, Michael
    Q:collectionView.register() keeps crashing the app as there's a nil value
    A:collectionView.register() should be used if we programmatically create a collectionViewCell, since I'm doing it on the storyboard, once I used register, it'll create a new collectionViewCell which is not my custom cell. Solved by deleting the register()
 11/2, Emma
    Q: When user tries to get the detailed info of a movie from favorite, the detailedViewController keeps throwing error message that indicates there's no Movie object passed into it. I checked the Movie object did pass to the detailedViewController by print everything out.
    A: Emma suggested that I may create another detailedViewController for favorite only, detailedViewController_fav in my case, and just redo the whole things again just like I did in the detailedViewController. It works, but I don't know why my origial way cannot work out.
 11/3 Michael
    Make sure I did what the graders expected. Michael said everything looks fine.
 */

/*
 Source of custom images:
 Favorite: https://icons-for-free.com/favorite-131964743718929326/
 Setting: https://icons-for-free.com/setting+icon-1320183839547990505/
 Movie: https://icons-for-free.com/movie+filter+48px-131985227424553010/
 */


// This swift file is largely based on lecture 7 which contains materials of how to use collection view
import UIKit
import SystemConfiguration

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIContextMenuInteractionDelegate{
    
    // Implement the context menu for extra credit,
    // Learned context menu from https://stackoverflow.com/questions/61158026/how-to-know-which-uicollectionview-cell-is-triggered-for-context-menu-on-ios-13
    // and https://blog.apphud.com/context-menus/
    // Simply implement the delegate method by returning a UIContextMenuConfiguration
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier:nil, previewProvider: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){
            suggestedActions in
            let favoriteMovieList = UserDefaults.standard.array(forKey: "movieDB") as? [Data] ?? []
            var isFav:Bool!
            if favoriteMovieList.count == 0{
                isFav = false
            }else{
                for eachData in favoriteMovieList{
                    let tempDecoded = try! NSKeyedUnarchiver.unarchivedObject(ofClass: StoredMovie.self, from: eachData)
                    if tempDecoded?.title == self.theMovieList[indexPath.row].title{
                        isFav = true
                        break
                    }else{
                        isFav = false
                    }
                }
            }
            var fav:UIAction!
            if isFav == false{
                fav = UIAction(title: "Add to Favorite", image: UIImage(systemName: "star")){ _ in
                    self.addToFav(index: indexPath.row)
                    fav.title = "Remove from Favorite"
                    fav.image = UIImage(systemName:"star.fill")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFavInDetail"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
//                    print("add through menu")
                }
            }else{
                fav = UIAction(title: "Remove from Favorite", image: UIImage(systemName: "star.fill")){_ in
                    self.removeFromFav(index: indexPath.row)
                    fav.title = "Add to Favorite"
                    fav.image = UIImage(systemName: "star")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFavInDetail"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
//                    print("delete through menu")
                }
            }
            return UIMenu(title:"Options", children: [fav])
        }
        return config
    }
    
    /*
     addToFav and removeFromFav are solely used in context menu. These methods are pretty similar to the one in detailedViewController.
     */
    private func addToFav(index:Int){
        let rawImageData = theImageCache[index]
        let nsImageData = rawImageData.jpegData(compressionQuality: 0.2)! as NSData
        let tempData = StoredMovie(movieId: theMovieList[index].id, moviePoster: theMovieList[index].poster_path, movieTitle: theMovieList[index].title, movieDate: theMovieList[index].release_date, movieRating: theMovieList[index].vote_average, movieOverview: theMovieList[index].overview, movieVote: theMovieList[index].vote_count)
        let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: tempData, requiringSecureCoding: true)
        var favMovieList = UserDefaults.standard.array(forKey: "movieDB") as? [Data] ?? []
        var favMovieImageList = UserDefaults.standard.array(forKey: "movieImageDB") as? [NSData] ?? []
        favMovieList.append(encodedData)
        favMovieImageList.append(nsImageData)
        UserDefaults.standard.set(favMovieList, forKey: "movieDB")
        UserDefaults.standard.set(favMovieImageList, forKey: "movieImageDB")
    }
    
    private func removeFromFav(index:Int){
        var favMovieList = UserDefaults.standard.array(forKey: "movieDB") as? [Data] ?? []
        var favMovieImageList = UserDefaults.standard.array(forKey: "movieImageDB") as? [NSData] ?? []
        for i in 0..<favMovieList.count{
            let decoded = try! NSKeyedUnarchiver.unarchivedObject(ofClass: StoredMovie.self, from: favMovieList[i])
            if decoded?.title == theMovieList[index].title{
                favMovieList.remove(at: i)
                favMovieImageList.remove(at: i)
                UserDefaults.standard.set(favMovieList, forKey: "movieDB")
                UserDefaults.standard.set(favMovieImageList, forKey: "movieImageDB")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFavInDetail"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return theImageCache.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MainpageCollectionViewCell
        cell.cellImage.image = theImageCache[indexPath.row]
        cell.cellTitle.text = theMovieTitle[indexPath.row]
        return cell
    }
    
    /*
     Network reachability is learned from: https://www.youtube.com/watch?v=AoSGcDNmbxo
     I have this creative idea since the suggested creative idea on piazza which recommend us to store everything on local device so users can see their favorite movie detailed info even when they are out of Internet Service.
     */
    private let reachability = SCNetworkReachabilityCreateWithName(nil, "https://api.themoviedb.org/3/movie/76341?api_key=cce40c278cee1f3184538b6bbf16e418")
    
    private func checkReachability(){
        var flag = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(self.reachability!, &flag)
        if isNetworkReachable(with:flag){
            if flag.contains(.reachable){
                isConnected = true
            }
        }else{
            isConnected = false
            // Learned how to use alert on lab 3, here's the link I learned on lab 3 and this assignment: https://stackoverflow.com/questions/25511945/swift-alert-view-with-ok-and-cancel-which-button-tapped
            let ac = UIAlertController(title: "No Connection", message: "No Internet connection. Please try again later.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    private func isNetworkReachable(with flag:SCNetworkReachabilityFlags) -> Bool{
        let isReachable = flag.contains(.reachable)
        let connectRequired = flag.contains(.connectionRequired)
        let canAutoConnect = flag.contains(.connectionOnDemand) || flag.contains(.connectionOnTraffic)
        let canConnectWithoutInteraction = canAutoConnect && !flag.contains(.interventionRequired)
        return isReachable && (!connectRequired || canConnectWithoutInteraction)
    }
    // end of quote of network reachability

    var isConnected:Bool!
    @IBOutlet weak var searchSpinner: UIActivityIndicatorView!
    @IBOutlet weak var mainPageSpinner: UIActivityIndicatorView!
    @IBOutlet weak var theSearchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var theDataResult: [APIResults?] = []
    var theImageCache:[UIImage] = []
    var theMovieTitle:[String] = []
    var theMovieList:[Movie] = []
    @IBOutlet weak var searchBarText: UISearchBar!
    
    var adultContent:String = "true"
    var currentPage:Int = 1
    var curLanguage:String = "en-US"
    var isSearching:Bool = false
    var isLoading:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkReachability()
        setupCollectionView()
        self.searchSpinner.isHidden = false
        self.searchSpinner.startAnimating()
        // DispatchQueue learned from lecture videos, lecture 10
        DispatchQueue.global(qos: .background).async {
            self.getMovieData(page: self.currentPage)
            self.cacheImage(page: self.currentPage)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.searchSpinner.stopAnimating()
                self.searchSpinner.isHidden = true
                self.isLoading = false
                settingPass.shareInstance.isLoading = false
            }
        }
        // Learned how to use observer https://stackoverflow.com/questions/54146841/swift-ios-how-to-update-using-observers
        NotificationCenter.default.addObserver(self, selector: #selector(settingSetup), name: Notification.Name(rawValue: "changeSetting"), object: nil)
        let interaction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interaction)
    }
    
    // A function that set the language and adult content variables, then to perfrom query.
    @objc func settingSetup(){
        checkReachability()
        if(isConnected == true){
            isLoading = true
            settingPass.shareInstance.isLoading = true
    //        print(settingPass.shareInstance.language)
            curLanguage = settingPass.shareInstance.language
            adultContent = settingPass.shareInstance.adultContent
            searchBarText.text = ""
            isSearching = false
            theDataResult = []
            theMovieList = []
            theImageCache = []
            theMovieTitle = []
            collectionView.reloadData()
            self.searchSpinner.isHidden = false
            self.searchSpinner.startAnimating()
            DispatchQueue.global(qos: .background).async {
                self.currentPage = 1
                self.getMovieData(page: self.currentPage)
                self.cacheImage(page: self.currentPage)
                DispatchQueue.main.async {
                    self.searchSpinner.isHidden = true
                    self.searchSpinner.stopAnimating()
                    self.collectionView.reloadData()
                    self.collectionView.setContentOffset(CGPoint.zero, animated: true)
                    self.isLoading = false
                    settingPass.shareInstance.isLoading = false
                }
            }
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if(indexPath.row == theMovieTitle.count - 1 && isSearching == false && isLoading == false){
            checkReachability()
            if isConnected == true{
                isLoading = true
                settingPass.shareInstance.isLoading = true
                self.mainPageSpinner.isHidden = false
                self.mainPageSpinner.startAnimating()
                DispatchQueue.global().async {
                    self.currentPage += 1
                    self.getMovieData(page: self.currentPage)
                    self.cacheImage(page: self.currentPage)
                    DispatchQueue.main.async {
                        collectionView.reloadData()
                        self.mainPageSpinner.stopAnimating()
                        self.mainPageSpinner.isHidden = true
                        self.isLoading = false
                        settingPass.shareInstance.isLoading = false
                    }
                }
            }
        }
    }
    
    /*
    Quoted from: https://www.themoviedb.org/settings/api
    Initically, we load some movies to display in mainpage
    */
    func getMovieData(page: Int){
        checkReachability()
        if(isConnected == true){
            let apiKey = "cce40c278cee1f3184538b6bbf16e418"
            let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&include_adult=\(adultContent)&page=\(page)&language=\(curLanguage)&sort_by=popularity.desc")
            guard let data = try? Data(contentsOf: url!) else { return  }
            let tempResult = [try? JSONDecoder().decode(APIResults.self, from: data)]
            theDataResult.append(contentsOf: tempResult)
        }
    }

    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        theSearchBar.delegate = self
        mainPageSpinner.isHidden = true
        searchSpinner.isHidden = true
    }
    
    // The source of error image: https://www.iconsdb.com/red-icons/error-4-icon.html
    // The function is suggested by lecture video 10.
    func cacheImage(page: Int){
        checkReachability()
        if isConnected == true{
//            print(theDataResult)
            for movie in theDataResult[page-1]!.results{
                if movie.poster_path != nil{
                    let posterPath = movie.poster_path!
                    let imagePath = URL(string:"https://image.tmdb.org/t/p/w500" + posterPath)
                    let imageData = try? Data(contentsOf: imagePath!)
                    if imageData != nil{
                        let movieImage = UIImage(data: imageData!)
                        theImageCache.append(movieImage!)
                    }else{
                        let movieImage = UIImage(data: (UIImage(named: "error")?.jpegData(compressionQuality: 0.5))!)
                        theImageCache.append(movieImage!)
                    }
                } else{
                    let movieImage = UIImage(named: "error")
                    theImageCache.append(movieImage!)
                }
                theMovieList.append(movie)
                theMovieTitle.append(movie.title)
            }
        }
    }
    
    // Learned from https://www.raywenderlich.com/4363809-uisearchcontroller-tutorial-getting-started
    // Learned spinner from https://stackoverflow.com/questions/28865659/hide-activity-indicator
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        checkReachability()
        if isConnected == true && isLoading == false{
            let searchText = theSearchBar.text?.replacingOccurrences(of: " ", with: "+")
    //        print(searchText)
            if searchText != nil && searchText! != ""{
                theDataResult = []
                theMovieList = []
                theImageCache = []
                theMovieTitle = []
                collectionView.reloadData()
                isSearching = true
                searchSpinner.isHidden = false
                searchSpinner.startAnimating()
                let apiKey = "cce40c278cee1f3184538b6bbf16e418"
                let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(searchText!)&include_adult=\(self.adultContent)&language=\(self.curLanguage)")
//                print(url)
                let data = try? Data(contentsOf: url!)
                let tempResult = [try? JSONDecoder().decode(APIResults.self, from: data!)]
                self.theDataResult = tempResult
//                    print(tempResult)
//                    print(self.theDataResult)
//                    print(self.theDataResult.count)
                // If there are so matches. Get the info to display
                if self.theDataResult[0] != nil{
                    DispatchQueue.global().async {
                    for movie in self.theDataResult[0]!.results{
                        // If the poster is not nil, get the image and store in imageCache array
                        if movie.poster_path != nil{
                            let posterPath = movie.poster_path!
                            let imagePath = URL(string: "https://image.tmdb.org/t/p/w500" + posterPath)
                            let imageData = try! Data(contentsOf: imagePath!)
                            let movieImage = UIImage(data: imageData)
                            self.theImageCache.append(movieImage!)
                        } else{
                            // If poster is nil, use the error image.
                            let movieImage = UIImage(named: "error")
                            self.theImageCache.append(movieImage!)
                        }
                        self.theMovieList.append(movie)
                        self.theMovieTitle.append(movie.title)
        //                print(movie.title)
                        }
                        DispatchQueue.main.async {
                            self.searchSpinner.stopAnimating()
                            self.searchSpinner.isHidden = true
                            self.collectionView.setContentOffset(CGPoint.zero, animated: true)
                            self.collectionView.reloadData()
                        }
                    }
                }else{
                    // If there's no match, pop out a message (creative portion)
                    self.searchSpinner.stopAnimating()
                    self.searchSpinner.isHidden = true
                    self.collectionView.setContentOffset(CGPoint.zero, animated: true)
                    self.collectionView.reloadData()
                    let ac = UIAlertController(title: "No match!", message: "Your search did not match any movies.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            }else{
                // If the search text is nil or an empty string, load the main page again.
                isSearching = false
                isLoading = true
                settingPass.shareInstance.isLoading = true
                theMovieList = []
                theDataResult = []
                theImageCache = []
                theMovieTitle = []
                collectionView.reloadData()
                searchSpinner.isHidden = false
                searchSpinner.startAnimating()
                DispatchQueue.global().async {
                    self.currentPage = 1
                    self.getMovieData(page: self.currentPage)
                    self.cacheImage(page: self.currentPage)
                    DispatchQueue.main.async {
                        self.searchSpinner.isHidden = true
                        self.searchSpinner.stopAnimating()
                        self.collectionView.reloadData()
                        self.collectionView.setContentOffset(CGPoint.zero, animated: true)
                        self.isLoading = false
                        settingPass.shareInstance.isLoading = false
                    }
                }
                
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        checkReachability()
        if isConnected == true{
            if segue.identifier == "detailed"{
                let detailedVC = segue.destination as! DetailedViewController
    //            detailedVC.loadView()
    //            detailedVC.detailedImage.image = theImageCache[sender as! Int]
    //            detailedVC.detailedTitle.text = theMovieTitle[sender as! Int]
                detailedVC.movie = theMovieList[sender as! Int]
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailed", sender: indexPath.row)
    }
}
