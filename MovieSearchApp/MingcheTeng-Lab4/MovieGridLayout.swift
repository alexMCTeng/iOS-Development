import UIKit

/// Recomputes the grid from its current usable width, including during rotation.
final class MovieGridLayout: UICollectionViewFlowLayout {
    private let preferredWidth: CGFloat = 179
    private let minimumWidth: CGFloat = 140
    private let cellAspectRatio: CGFloat = 187 / 179

    override init() {
        super.init()
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        sectionInsetReference = .fromContentInset
    }

    required init?(coder: NSCoder) {
        fatalError("Create MovieGridLayout programmatically")
    }

    override func prepare() {
        if let collectionView = collectionView {
            let insets = collectionView.adjustedContentInset
            let availableWidth = max(0, collectionView.bounds.width - insets.left - insets.right)
            if availableWidth > 0 {
                let spacing = minimumInteritemSpacing
                let minimumColumns = availableWidth >= 2 * minimumWidth + spacing ? 2 : 1
                let columns = max(minimumColumns, Int((availableWidth + spacing) / (preferredWidth + spacing)))
                let scale = max(collectionView.traitCollection.displayScale, 1)
                // Leave a pixel of slack so fractional transition widths cannot wrap a cell.
                let fittingWidth = (availableWidth - 1 / scale - CGFloat(columns - 1) * spacing) / CGFloat(columns)
                let width = max(1 / scale, floor(min(preferredWidth, fittingWidth) * scale) / scale)
                let size = CGSize(width: width, height: floor(width * cellAspectRatio * scale) / scale)
                if itemSize != size { itemSize = size }

                let count = collectionView.numberOfSections > 0 ? collectionView.numberOfItems(inSection: 0) : 0
                let rowCount = min(count, columns)
                let rowWidth = CGFloat(rowCount) * width + CGFloat(max(rowCount - 1, 0)) * spacing
                let margin = rowCount > 0 ? max(0, floor((availableWidth - rowWidth) / 2 * scale) / scale) : 0
                let padding = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
                if sectionInset != padding { sectionInset = padding }
            }
        }
        super.prepare()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width || super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
