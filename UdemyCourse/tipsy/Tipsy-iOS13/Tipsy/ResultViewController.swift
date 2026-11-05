import UIKit

final class ResultViewController: UIViewController {
    private let totalPerPerson: Double
    private let people: Int
    private let tipPercentage: Int

    init(totalPerPerson: Double, people: Int, tipPercentage: Int) {
        self.totalPerPerson = totalPerPerson
        self.people = people
        self.tipPercentage = tipPercentage
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(totalPerPerson:people:tipPercentage:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TipsyStyle.background

        let header = UIView()
        header.backgroundColor = TipsyStyle.mint
        let title = TipsyStyle.label("Total per person", size: 30)
        title.textAlignment = .center
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let total = UILabel()
        total.text = formatter.string(from: NSNumber(value: totalPerPerson))
        total.font = .boldSystemFont(ofSize: 45)
        total.textColor = TipsyStyle.green
        total.textAlignment = .center
        total.adjustsFontSizeToFitWidth = true
        total.minimumScaleFactor = 0.3
        total.accessibilityIdentifier = "totalPerPerson"
        let detail = TipsyStyle.label("Split between \(people) people, with \(tipPercentage)% tip.", size: 25)
        detail.numberOfLines = 0
        detail.textAlignment = .center
        let recalculateButton = TipsyStyle.button("Recalculate")
        recalculateButton.addTarget(self, action: #selector(recalculate), for: .touchUpInside)

        for subview in [header, detail, recalculateButton] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        for subview in [title, total] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            header.addSubview(subview)
        }
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 300),
            title.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            title.heightAnchor.constraint(equalToConstant: 36),
            total.topAnchor.constraint(equalTo: title.bottomAnchor),
            total.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            total.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            total.heightAnchor.constraint(equalToConstant: 100),
            detail.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 5),
            detail.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 50),
            detail.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -50),
            detail.heightAnchor.constraint(equalToConstant: 117),
            recalculateButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            recalculateButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            recalculateButton.topAnchor.constraint(greaterThanOrEqualTo: detail.bottomAnchor, constant: 20),
            recalculateButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            recalculateButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    @objc private func recalculate() {
        dismiss(animated: true)
    }
}
