import UIKit

/// Shared layout for online movie details and locally saved favorites.
/// Change `contentMargin` and the stack spacing here to adjust both screens.
final class MovieDetailView: UIView {
    private let contentMargin: CGFloat = 20
    let posterView = UIImageView()
    let titleLabel = UILabel()
    let ratingLabel = UILabel()
    let overviewLabel = UILabel()
    let dateLabel = UILabel()
    let favoriteLabel = UILabel()
    let favoriteButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        titleLabel.font = .systemFont(ofSize: 30, weight: .medium)
        titleLabel.numberOfLines = 0
        posterView.contentMode = .scaleAspectFit
        posterView.clipsToBounds = true
        ratingLabel.font = .boldSystemFont(ofSize: 50)
        ratingLabel.textColor = .systemRed
        ratingLabel.adjustsFontSizeToFitWidth = true
        ratingLabel.minimumScaleFactor = 0.5
        overviewLabel.font = .preferredFont(forTextStyle: .body)
        overviewLabel.adjustsFontForContentSizeCategory = true
        overviewLabel.numberOfLines = 0
        dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        dateLabel.numberOfLines = 0
        favoriteLabel.font = .preferredFont(forTextStyle: .body)
        favoriteLabel.numberOfLines = 0
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.accessibilityLabel = "Add to Favorite"
        favoriteButton.accessibilityIdentifier = "movie.favorite"

        let ratingScale = label("/10")
        ratingScale.setContentCompressionResistancePriority(.required, for: .horizontal)
        ratingLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let score = UIStackView(arrangedSubviews: [ratingLabel, ratingScale])
        score.alignment = .firstBaseline
        score.spacing = 4
        let rating = UIStackView(arrangedSubviews: [label("Avg. Rating"), score])
        rating.axis = .vertical
        rating.spacing = 8
        let posterAndRating = UIStackView(arrangedSubviews: [posterView, rating])
        posterAndRating.spacing = 16
        posterAndRating.alignment = .center

        let release = UIStackView(arrangedSubviews: [label("Release Date:"), dateLabel])
        release.axis = .vertical
        release.spacing = 4
        let favorite = UIStackView(arrangedSubviews: [favoriteButton, favoriteLabel])
        favorite.spacing = 8
        favorite.alignment = .center
        let content = UIStackView(arrangedSubviews: [
            titleLabel, posterAndRating, label("Movie Overview:"),
            overviewLabel, release, favorite
        ])
        content.axis = .vertical
        content.spacing = 16
        content.setCustomSpacing(4, after: content.arrangedSubviews[2])

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        addSubview(scrollView)
        scrollView.addSubview(content)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        let posterWidth = posterView.widthAnchor.constraint(equalTo: content.widthAnchor, multiplier: 0.55)
        posterWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: contentMargin),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: contentMargin),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -contentMargin),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -contentMargin),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -2 * contentMargin),
            posterWidth,
            posterView.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
            posterView.heightAnchor.constraint(equalTo: posterView.widthAnchor, multiplier: 1.3),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Create MovieDetailView programmatically")
    }

    private func label(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        return label
    }
}
