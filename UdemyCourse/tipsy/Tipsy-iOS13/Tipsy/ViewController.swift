import UIKit

final class ViewController: UIViewController {
    private let billTextField = UITextField()
    private let splitLabel = UILabel()
    private let splitStepper = UIStepper()
    private var tipButtons: [UIButton] = []
    private var tipPercentage = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TipsyStyle.background
        configureBillField()
        configureLayout()
        updateTipSelection()
    }

    private func configureBillField() {
        billTextField.placeholder = "e.g. 123.56"
        billTextField.font = .systemFont(ofSize: 40)
        billTextField.textColor = TipsyStyle.green
        billTextField.textAlignment = .center
        billTextField.keyboardType = .decimalPad
        billTextField.accessibilityLabel = "Bill total"
        billTextField.accessibilityIdentifier = "billTotal"

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))
        ]
        billTextField.inputAccessoryView = toolbar
    }

    private func configureLayout() {
        let billTitle = TipsyStyle.label("Enter bill total", size: 25)
        let optionsView = UIView()
        optionsView.backgroundColor = TipsyStyle.mint
        let tipTitle = TipsyStyle.label("Select tip", size: 25)
        let splitTitle = TipsyStyle.label("Choose Split", size: 25)

        tipButtons = [0, 10, 20].map { percentage in
            let button = UIButton(type: .custom)
            button.tag = percentage
            button.setTitle("\(percentage)%", for: .normal)
            button.setTitleColor(TipsyStyle.green, for: .normal)
            button.setTitleColor(TipsyStyle.background, for: .selected)
            button.titleLabel?.font = .systemFont(ofSize: 35)
            button.layer.cornerRadius = 10
            button.accessibilityLabel = "\(percentage) percent tip"
            button.accessibilityIdentifier = "tip\(percentage)"
            button.addTarget(self, action: #selector(selectTip(_:)), for: .touchUpInside)
            return button
        }
        let tipStack = UIStackView(arrangedSubviews: tipButtons)
        tipStack.distribution = .fillEqually
        tipStack.spacing = 8

        splitLabel.text = "2"
        splitLabel.font = .systemFont(ofSize: 35)
        splitLabel.textColor = TipsyStyle.green
        splitLabel.textAlignment = .center
        splitLabel.accessibilityIdentifier = "splitCount"
        splitStepper.minimumValue = 2
        splitStepper.maximumValue = 25
        splitStepper.value = 2
        splitStepper.accessibilityLabel = "Number of people"
        splitStepper.accessibilityValue = "2"
        splitStepper.addTarget(self, action: #selector(changeSplit(_:)), for: .valueChanged)
        let splitStack = UIStackView(arrangedSubviews: [splitLabel, splitStepper])
        splitStack.spacing = 27
        splitStack.alignment = .center

        let calculateButton = TipsyStyle.button("Calculate")
        calculateButton.addTarget(self, action: #selector(calculate), for: .touchUpInside)

        for subview in [billTitle, billTextField, optionsView, calculateButton] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        for subview in [tipTitle, tipStack, splitTitle, splitStack] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            optionsView.addSubview(subview)
        }
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            billTitle.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            billTitle.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 50),
            billTitle.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -50),
            billTitle.heightAnchor.constraint(equalToConstant: 30),
            billTextField.topAnchor.constraint(equalTo: billTitle.bottomAnchor, constant: 26),
            billTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            billTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            billTextField.heightAnchor.constraint(equalToConstant: 48),
            optionsView.topAnchor.constraint(equalTo: billTextField.bottomAnchor, constant: 40),
            optionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tipTitle.topAnchor.constraint(equalTo: optionsView.topAnchor, constant: 20),
            tipTitle.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 50),
            tipTitle.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -50),
            tipTitle.heightAnchor.constraint(equalToConstant: 30),
            tipStack.topAnchor.constraint(equalTo: tipTitle.bottomAnchor, constant: 26),
            tipStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            tipStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            tipStack.heightAnchor.constraint(equalToConstant: 54),
            splitTitle.topAnchor.constraint(equalTo: tipStack.bottomAnchor, constant: 26),
            splitTitle.leadingAnchor.constraint(equalTo: tipTitle.leadingAnchor),
            splitTitle.trailingAnchor.constraint(equalTo: tipTitle.trailingAnchor),
            splitTitle.heightAnchor.constraint(equalToConstant: 30),
            splitStack.topAnchor.constraint(equalTo: splitTitle.bottomAnchor, constant: 26),
            splitStack.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            splitLabel.widthAnchor.constraint(equalToConstant: 93),
            calculateButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            calculateButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            calculateButton.topAnchor.constraint(greaterThanOrEqualTo: splitStack.bottomAnchor, constant: 20),
            calculateButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            calculateButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    @objc private func selectTip(_ sender: UIButton) {
        endEditing()
        tipPercentage = sender.tag
        updateTipSelection()
    }

    private func updateTipSelection() {
        for button in tipButtons {
            button.isSelected = button.tag == tipPercentage
            button.backgroundColor = button.isSelected ? TipsyStyle.green : .clear
        }
    }

    @objc private func changeSplit(_ sender: UIStepper) {
        splitLabel.text = String(Int(sender.value))
        sender.accessibilityValue = splitLabel.text
    }

    @objc private func calculate() {
        endEditing()
        let input = (billTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let separator = Locale.current.decimalSeparator ?? "."
        let normalizedInput = input.replacingOccurrences(of: separator, with: ".")
        guard let bill = Double(normalizedInput), bill.isFinite, bill >= 0 else {
            showInvalidBillAlert()
            return
        }
        let people = Int(splitStepper.value)
        let total = bill * (1 + Double(tipPercentage) / 100) / Double(people)
        guard total.isFinite else {
            showInvalidBillAlert()
            return
        }
        let result = ResultViewController(totalPerPerson: total, people: people, tipPercentage: tipPercentage)
        result.modalPresentationStyle = .fullScreen
        present(result, animated: true)
    }

    private func showInvalidBillAlert() {
        let alert = UIAlertController(title: "Enter a valid bill", message: "Please enter a bill total of zero or more.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
