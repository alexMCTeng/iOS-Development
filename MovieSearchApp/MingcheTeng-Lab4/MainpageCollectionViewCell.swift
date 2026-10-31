//
//  myCollectionViewCell.swift
//  MingcheTeng-Lab4
//
//  Created by AlexTeng on 10/27/20.
//  Copyright © 2020 AlexTeng. All rights reserved.
//


// Use this to set the image and title in the main page
import UIKit

class MainpageCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "movieCell"
    let cellImage = UIImageView()
    let cellTitle = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        cellImage.contentMode = .scaleAspectFit
        cellImage.clipsToBounds = true
        cellTitle.font = .systemFont(ofSize: 17)
        cellTitle.numberOfLines = 2
        cellTitle.textAlignment = .center
        cellTitle.backgroundColor = .opaqueSeparator
        for subview in [cellImage, cellTitle] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellTitle.heightAnchor.constraint(equalToConstant: 43)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Create MainpageCollectionViewCell programmatically")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
        cellTitle.text = nil
    }
}
