// ViewController.swift

import UIKit




struct Balance {
    var title: String
    var value: String
}


func extractArrays(from balances: [Balance]) -> (titles: [String], values: [String]) {
    var titlesArray = [String]()
    var valuesArray = [String]()
    
    for balance in balances {
        titlesArray.append(balance.title)
        valuesArray.append(balance.value)
    }
    
    return (titlesArray, valuesArray)
}

class ViewController: UIViewController,GetIndexOfSelecetedBalanceDelegate {
    @IBOutlet weak var horizontalBalanceView: HorizontalBalanceView!
    
    let balances = [
        Balance(title: "Income", value: "৳50,0000000"),
        Balance(title: "Remmitance", value: "৳123502"),
//        Balance(title: "Others", value: "৳50,00"),
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        horizontalBalanceView.delegate = self
        let (titles, values) = extractArrays(from: balances)
        horizontalBalanceView.setup(balancesTitle: titles, balancesValue: values)
    }
    
    func getIndex(_ index: Int) {
        print(balances[index].title)
    }
}


import UIKit


protocol BalanceViewDelegate: AnyObject {
    func balanceViewDidSelect(_ balanceView: BalanceView)
}

protocol GetIndexOfSelecetedBalanceDelegate: AnyObject {
    func getIndex(_ index: Int)
}
class HorizontalBalanceView: UIView, BalanceViewDelegate {
    var selectedBalanceView: BalanceView?
    weak var delegate: GetIndexOfSelecetedBalanceDelegate?
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStackView()
    }
    
    func setup(balancesTitle: [String],balancesValue: [String]) {
        for (index, balance) in balancesTitle.enumerated() {
            let balanceView = BalanceView()
            balanceView.index = index // Assign the index to the BalanceView
            balanceView.configure(balanceTitle: balancesTitle[index], balanceValue: balancesValue[index])
            balanceView.delegate = self
            if index == 0 {
                balanceView.button.isSelected = true
                selectedBalanceView = balanceView
            }
            stackView.addArrangedSubview(balanceView)
        }
    }
    
    private func setupStackView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func balanceViewDidSelect(_ balanceView: BalanceView) {
        if let selected = selectedBalanceView {
            selected.button.isSelected = false
        }
        selectedBalanceView = balanceView
        delegate?.getIndex(balanceView.index)
    }
}


import UIKit

class BalanceView: UIView {
    var index: Int = 0
    weak var delegate: BalanceViewDelegate?
    public let button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circleSelected"), for: .selected)
        button.setImage(UIImage(named: "circleDisSelected"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = hexStringToUIColor(hex: "#5B5B5B").withAlphaComponent(1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Fixed frame size for BalanceView
    let fixedFrameSize = CGSize(width: 100, height: 190)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: .zero, size: fixedFrameSize))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func configure(balanceTitle: String,balanceValue: String) {
        nameLabel.text = balanceTitle
        amountLabel.text = balanceValue
    }
    
    private func setupUI() {
        backgroundColor = hexStringToUIColor(hex: "#F5F5F5").withAlphaComponent(1)
        layer.cornerRadius = 8.0
        addSubview(button)
        addSubview(nameLabel)
        addSubview(amountLabel)
        configureButton()
        configureText()
    }
    
    private func configureButton() {
        addSubview(button)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Constraints for the button
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            button.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            button.widthAnchor.constraint(equalToConstant: 12),
            button.heightAnchor.constraint(equalToConstant: 12),
        ])
    }
    
    private func configureText() {
        let padding: CGFloat = 25.0
        
        // Constraints for nameLabel
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 0),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            nameLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        // Constraints for amountLabel
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            amountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            amountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            amountLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func buttonTapped() {
        delegate?.balanceViewDidSelect(self)
        button.isSelected.toggle()
    }
}


func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
