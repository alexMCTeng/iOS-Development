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
import Network

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIContextMenuInteractionDelegate {

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainpageCollectionViewCell.reuseIdentifier, for: indexPath) as! MainpageCollectionViewCell
        cell.cellImage.image = theImageCache[indexPath.row]
        cell.cellTitle.text = theMovieTitle[indexPath.row]
        return cell
    }

    /*
     Network reachability uses NWPathMonitor from the Network framework (replaces deprecated SCNetworkReachability).
     */
    private let pathMonitor = NWPathMonitor()
    private var hasStartedInitialLoad = false

    private func checkReachability() -> Bool {
        guard pathMonitor.currentPath.status == .satisfied else {
            // Loading methods also call this from background queues.
            DispatchQueue.main.async { [weak self] in
                self?.showNoConnectionAlert()
            }
            return false
        }
        return true
    }

    func showNoConnectionAlert() {
        guard viewIfLoaded?.window != nil, presentedViewController == nil else { return }
        let ac = UIAlertController(title: "No Connection", message: "No Internet connection. Please try again later.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }

    func handleNetworkPathUpdate(_ status: NWPath.Status) {
        // Path updates and startup state belong to the main queue.
        dispatchPrecondition(condition: .onQueue(.main))
        guard !hasStartedInitialLoad else { return }
        guard status == .satisfied else {
            searchSpinner.stopAnimating()
            isLoading = false
            settingPass.shareInstance.isLoading = false
            showNoConnectionAlert()
            return
        }
        hasStartedInitialLoad = true
        loadInitialMovies()
    }
    // end of network reachability

    private let searchSpinner = UIActivityIndicatorView(style: .large)
    private let mainPageSpinner = UIActivityIndicatorView(style: .medium)
    private let theSearchBar = UISearchBar()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: MovieGridLayout())
    var theDataResult: [APIResults?] = []
    var theImageCache:[UIImage] = []
    var theMovieTitle:[String] = []
    var theMovieList:[Movie] = []

    var adultContent:String = "true"
    var currentPage:Int = 1
    var curLanguage:String = "en-US"
    var isSearching:Bool = false
    var isLoading:Bool = true

    deinit {
        pathMonitor.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(settingSetup), name: Notification.Name(rawValue: "changeSetting"), object: nil)
        let interaction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interaction)
        guard TMDBConfiguration.apiKey != nil else {
            isLoading = false
            settingPass.shareInstance.isLoading = false
            theSearchBar.searchTextField.isEnabled = false
            let message = UILabel()
            message.text = "Movie service is not configured."
            message.textAlignment = .center
            message.numberOfLines = 0
            message.textColor = .secondaryLabel
            collectionView.backgroundView = message
            return
        }
        // currentPath is not ready synchronously after start. Wait for a path
        // update before checking connectivity or attempting the initial load.
        self.searchSpinner.isHidden = false
        self.searchSpinner.startAnimating()
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.handleNetworkPathUpdate(path.status)
        }
        pathMonitor.start(queue: .main)
    }

    func loadInitialMovies() {
        isLoading = true
        settingPass.shareInstance.isLoading = true
        searchSpinner.isHidden = false
        searchSpinner.startAnimating()
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
    }

    // A function that set the language and adult content variables, then to perfrom query.
    @objc func settingSetup(){
        guard TMDBConfiguration.apiKey != nil else { return }
        if checkReachability() {
            isLoading = true
            settingPass.shareInstance.isLoading = true
    //        print(settingPass.shareInstance.language)
            curLanguage = settingPass.shareInstance.language
            adultContent = settingPass.shareInstance.adultContent
            theSearchBar.text = ""
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
            if checkReachability() {
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
        guard let apiKey = TMDBConfiguration.apiKey else { return }
        if checkReachability() {
            let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&include_adult=\(adultContent)&page=\(page)&language=\(curLanguage)&sort_by=popularity.desc")
            guard let data = try? Data(contentsOf: url!) else { return  }
            let tempResult = [try? JSONDecoder().decode(APIResults.self, from: data)]
            theDataResult.append(contentsOf: tempResult)
        }
    }

    func setupCollectionView(){
        collectionView.backgroundColor = .systemBackground
        // The view is already constrained to the safe area; do not inset it again.
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        collectionView.register(MainpageCollectionViewCell.self,
                                forCellWithReuseIdentifier: MainpageCollectionViewCell.reuseIdentifier)
        theSearchBar.placeholder = "Search Movie"
        for subview in [theSearchBar, collectionView, mainPageSpinner] {
            view.addSubview(subview)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        theSearchBar.delegate = self
        setupMainPageLayout()
        setupSpinners()
        mainPageSpinner.isHidden = true
        searchSpinner.isHidden = true
    }

    private func setupMainPageLayout() {
        theSearchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        mainPageSpinner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            theSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            theSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            theSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            theSearchBar.heightAnchor.constraint(equalToConstant: 44),

            collectionView.topAnchor.constraint(equalTo: theSearchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            mainPageSpinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            mainPageSpinner.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }

    private func setupSpinners() {
        searchSpinner.hidesWhenStopped = true
        mainPageSpinner.hidesWhenStopped = true
        searchSpinner.frame = collectionView.bounds
        searchSpinner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundView = searchSpinner
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchSpinner.frame = collectionView.bounds

    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // The source of error image: https://www.iconsdb.com/red-icons/error-4-icon.html
    // The function is suggested by lecture video 10.
    func cacheImage(page: Int){
        guard theDataResult.indices.contains(page - 1) else { return }
        if checkReachability() {
//            print(theDataResult)
            if(theDataResult[page - 1] != nil){
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
    }

    // Learned from https://www.raywenderlich.com/4363809-uisearchcontroller-tutorial-getting-started
    // Learned spinner from https://stackoverflow.com/questions/28865659/hide-activity-indicator
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let apiKey = TMDBConfiguration.apiKey else { return }
        if !isLoading && checkReachability() {
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
                let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(searchText!)&include_adult=\(self.adultContent)&language=\(self.curLanguage)")
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Details use the movie and poster already loaded by the grid.
        let detail = DetailedViewController(movie: theMovieList[indexPath.row],
                                            image: theImageCache[indexPath.row])
        navigationController?.pushViewController(detail, animated: true)
    }

}
