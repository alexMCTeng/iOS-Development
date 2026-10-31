# Programmatic UIKit

`SceneDelegate.makeRootViewController()` creates the original Movie → Setting → Favorite tabs, each with its own navigation controller. `scene(_:willConnectTo:options:)` creates and retains the window. `Info.plist` no longer specifies a main or scene storyboard.

## Where to change layout

- `ViewController.swift`: movie grid, search field, loading indicators, and safe-area constraints in `setupMainPageLayout()`. The flow layout retains the 179 × 187 cell size, 10-point spacing, and centered rows.
- `MainpageCollectionViewCell.swift`: poster and two-line title overlay, built in `init(frame:)` and registered by the movie list.
- `MovieDetailView.swift`: shared scrollable layout for both detail controllers. Change `contentMargin` (20 points), stack spacing (16 points), and the poster constraints here.
- `FavoriteViewController.swift`: table pinned to the safe area.
- `SettingViewController.swift`: scrollable settings, picker, Save Changes button, TMDb logo and disclosure. Insets and spacing are 20 points in `setupLayout()`.

## Interactions

Movie and favorite selections construct `DetailedViewController(movie:image:)` or `DetailedViewController_fav(movie:image:)` and push them onto their navigation stack. A movie is now required at initialization. Poster images already loaded by the list are passed to details.

Buttons and segmented controls use `addTarget`; picker/search/collection/table delegates are assigned in code. Existing favorites storage, notifications, context menus, settings behavior, search, and pagination logic remain in the controllers.

`Main.storyboard` and its build references have been removed. `LaunchScreen.storyboard` remains solely for the system launch screen; it contains no application navigation or interactions.

## Verification

Open `MingcheTeng-Lab4.xcodeproj`, choose the shared **MingcheTeng-Lab4** scheme and an iOS Simulator, and press Command-U. `MovieSearchAppTests/ProgrammaticUITests.swift` covers tab construction, cell registration, both detail layouts at phone/landscape/iPad sizes, favorites button wiring and navigation, and settings control wiring. Detail/settings renders are attached to the test results.

For a manual end-to-end check with a working TMDb connection:

1. Browse movies, search, clear the search, and scroll to load another page.
2. Open a movie and verify the title, poster, rating, overview and release date; add/remove a favorite.
3. Long-press a movie and use its favorite context-menu action.
4. Open Favorite, select a saved movie, and remove it. Also verify saved details without a network connection.
5. Change adult content/language and tap Save Changes. Verify the loading guard and movie refresh.
6. Rotate each screen and scroll long details/settings content on a small device.

The UI migration does not replace the existing networking or persistence implementation. The regression tests use local movie data and do not validate live TMDb responses.
