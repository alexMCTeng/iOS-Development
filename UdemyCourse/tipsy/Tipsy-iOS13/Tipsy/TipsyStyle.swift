import UIKit

// The colors and typography from the original storyboard.
enum TipsyStyle {
    static let background = UIColor(red: 0.9725, green: 1, blue: 0.9922, alpha: 1)
    static let mint = UIColor(red: 0.8436, green: 0.9756, blue: 0.9232, alpha: 1)
    static let green = UIColor(red: 0, green: 0.6902, blue: 0.4196, alpha: 1)

    static func label(_ text: String, size: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: size)
        label.textColor = .lightGray
        return label
    }

    static func button(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(background, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 35)
        button.backgroundColor = green
        button.layer.cornerRadius = 10
        return button
    }
}
