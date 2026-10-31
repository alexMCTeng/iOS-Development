import XCTest
@testable import MingcheTeng_Lab4

@MainActor
final class ProgrammaticUITests: XCTestCase {
    private var savedDefaults: [String: Any] = [:]
    private let keys = ["movieDB", "movieImageDB"]
    private var savedLanguage = "en-US"
    private var savedAdult = "true"

    override func setUp() {
        super.setUp()
        for key in keys {
            savedDefaults[key] = UserDefaults.standard.object(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
        savedLanguage = settingPass.shareInstance.language
        savedAdult = settingPass.shareInstance.adultContent
    }

    override func tearDown() {
        for key in keys {
            UserDefaults.standard.set(savedDefaults[key], forKey: key)
        }
        settingPass.shareInstance.language = savedLanguage
        settingPass.shareInstance.adultContent = savedAdult
        super.tearDown()
    }

    private var movie: Movie {
        Movie(id: 42, poster_path: nil, title: "A long movie title for layout testing",
              release_date: "2020-11-01", vote_average: 8.25,
              overview: String(repeating: "An overview that must remain readable and scrollable. ", count: 30),
              vote_count: 100)
    }

    private var poster: UIImage { UIImage(named: "error")! }

    private func descendants<T: UIView>(_ view: UIView, of type: T.Type) -> [T] {
        if let match = view as? T { return [match] }
        return view.subviews.flatMap { descendants($0, of: type) }
    }

    func testRootHierarchyPreservesTabsAndNavigationStacks() throws {
        let tabs = SceneDelegate.makeRootViewController()
        let stacks = try XCTUnwrap(tabs.viewControllers as? [UINavigationController])
        XCTAssertEqual(stacks.map { $0.tabBarItem.title }, ["Movie", "Setting", "Favorite"])
        XCTAssertTrue(stacks[0].viewControllers[0] is ViewController)
        XCTAssertTrue(stacks[1].viewControllers[0] is SettingViewController)
        XCTAssertTrue(stacks[2].viewControllers[0] is FavoriteViewController)
        XCTAssertNil(Bundle.main.object(forInfoDictionaryKey: "UIMainStoryboardFile"))
        XCTAssertNil(Bundle.main.path(forResource: "Main", ofType: "storyboardc"))
    }

    func testRegisteredMovieCellBuildsAndLaysOutItsSubviews() {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 375, height: 700), collectionViewLayout: layout)
        collection.register(MainpageCollectionViewCell.self, forCellWithReuseIdentifier: MainpageCollectionViewCell.reuseIdentifier)
        let cell = collection.dequeueReusableCell(withReuseIdentifier: MainpageCollectionViewCell.reuseIdentifier,
                                                   for: IndexPath(item: 0, section: 0)) as! MainpageCollectionViewCell
        cell.frame = CGRect(x: 0, y: 0, width: 179, height: 187)
        cell.cellImage.image = poster
        cell.cellTitle.text = movie.title
        cell.layoutIfNeeded()
        XCTAssertEqual(cell.cellTitle.frame.height, 43, accuracy: 0.5)
        XCTAssertEqual(cell.cellTitle.frame.maxY, cell.contentView.bounds.maxY, accuracy: 0.5)
        XCTAssertFalse(cell.cellImage.hasAmbiguousLayout)
        cell.prepareForReuse()
        XCTAssertNil(cell.cellImage.image)
        XCTAssertNil(cell.cellTitle.text)
    }

    func testBothDetailScreensLoadWithoutOutletsAndScrollAtDifferentSizes() throws {
        let controllers: [UIViewController] = [
            DetailedViewController(movie: movie, image: poster),
            DetailedViewController_fav(movie: movie, image: poster)
        ]
        for controller in controllers {
            controller.loadViewIfNeeded()
            let detail = try XCTUnwrap(controller.view as? MovieDetailView)
            XCTAssertEqual(detail.titleLabel.text, movie.title)
            XCTAssertEqual(detail.ratingLabel.text, "8.2")
            XCTAssertEqual(detail.overviewLabel.text, movie.overview)
            XCTAssertEqual(detail.dateLabel.text, movie.release_date)
            let scroll = try XCTUnwrap(descendants(detail, of: UIScrollView.self).first)
            for size in [CGSize(width: 320, height: 568), CGSize(width: 844, height: 390), CGSize(width: 768, height: 1024)] {
                detail.frame = CGRect(origin: .zero, size: size)
                detail.setNeedsLayout()
                detail.layoutIfNeeded()
                XCTAssertGreaterThan(scroll.contentSize.height, 0)
                XCTAssertLessThanOrEqual(scroll.contentSize.width, scroll.bounds.width + 1)
                XCTAssertGreaterThan(detail.titleLabel.bounds.height, 0)
                XCTAssertFalse(detail.titleLabel.hasAmbiguousLayout)
                XCTAssertFalse(detail.posterView.hasAmbiguousLayout)
                XCTAssertFalse(detail.overviewLabel.hasAmbiguousLayout)
                let ratingScale = try XCTUnwrap(descendants(detail, of: UILabel.self).first { $0.text == "/10" })
                XCTAssertGreaterThanOrEqual(ratingScale.bounds.width, ratingScale.intrinsicContentSize.width - 1)
                attachLayout(detail, name: "\(type(of: controller))-\(Int(size.width))x\(Int(size.height))")
            }
        }
    }

    func testFavoriteButtonsPersistAndRemoveMovieAndUpdateList() throws {
        let favorites = FavoriteViewController()
        let navigation = UINavigationController(rootViewController: favorites)
        favorites.loadViewIfNeeded()
        let detail = DetailedViewController(movie: movie, image: poster)
        detail.loadViewIfNeeded()
        let detailView = try XCTUnwrap(detail.view as? MovieDetailView)
        detailView.favoriteButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(favorites.favoriteList.count, 1)
        XCTAssertEqual(detailView.favoriteLabel.text, "Remove")

        let table = try XCTUnwrap(descendants(favorites.view, of: UITableView.self).first)
        favorites.tableView(table, didSelectRowAt: IndexPath(row: 0, section: 0))
        let savedDetail = try XCTUnwrap(navigation.topViewController as? DetailedViewController_fav)
        XCTAssertEqual(savedDetail.movie.title, movie.title)
        savedDetail.loadViewIfNeeded()
        let savedView = try XCTUnwrap(savedDetail.view as? MovieDetailView)
        XCTAssertNotNil(savedView.posterView.image)
        savedView.favoriteButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(favorites.favoriteList.isEmpty)
        XCTAssertEqual(UserDefaults.standard.array(forKey: "movieImageDB")?.count, 0)
        XCTAssertTrue(navigation.topViewController === favorites)
    }

    func testSettingsControlsAreConnectedAndContentFitsNarrowScreen() throws {
        settingPass.shareInstance.adultContent = "false"
        settingPass.shareInstance.language = "ja"
        let settings = SettingViewController()
        settings.loadViewIfNeeded()
        settings.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        settings.view.layoutIfNeeded()
        let segments = try XCTUnwrap(descendants(settings.view, of: UISegmentedControl.self).first)
        let picker = try XCTUnwrap(descendants(settings.view, of: UIPickerView.self).first)
        let save = try XCTUnwrap(descendants(settings.view, of: UIButton.self).first { $0.title(for: .normal) == "Save Changes" })
        XCTAssertEqual(segments.selectedSegmentIndex, 1)
        XCTAssertEqual(picker.selectedRow(inComponent: 0), 2)
        segments.selectedSegmentIndex = 0
        segments.sendActions(for: .valueChanged)
        XCTAssertEqual(settingPass.shareInstance.adultContent, "true")
        picker.delegate?.pickerView?(picker, didSelectRow: 4, inComponent: 0)
        XCTAssertEqual(settingPass.shareInstance.language, "es")
        XCTAssertTrue(save.actions(forTarget: settings, forControlEvent: .touchUpInside)?.contains("saveBtnHit:") == true)
        let scroll = try XCTUnwrap(descendants(settings.view, of: UIScrollView.self).first)
        XCTAssertGreaterThan(scroll.contentSize.height, scroll.bounds.height)
        XCTAssertLessThanOrEqual(scroll.contentSize.width, scroll.bounds.width + 1)
        attachLayout(settings.view, name: "Settings-320x480")
    }

    private func attachLayout(_ view: UIView, name: String) {
        let image = UIGraphicsImageRenderer(bounds: view.bounds).image { context in
            view.layer.render(in: context.cgContext)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
