//
//  ViewController.swift
//  TMSLesson11
//
//  Created by Mac on 27.12.23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    var shouldClearTextBeforeInserting = false
    var calculatorButtons: [UIButton] = []
    var buttonOriginalColors: [UIButton: UIColor] = [:]
    let stackView = UIStackView()
    var firstNumber: Double?
    var secondNumber: Double?
    var operation: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
        setupConstraints()
    }
    
    func setupUI() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        
        textField.text = "0"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.black
        textField.textAlignment = .right
        textField.font = UIFont.systemFont(ofSize: 80)
        textField.textColor = UIColor.white
        
        view.addSubview(textField)
        view.addSubview(stackView)
        view.backgroundColor = UIColor.black
    }
    
    func setupConstraints() {
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let textFieldConstraints = [
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 200)
        ]
        
        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(textFieldConstraints + stackViewConstraints)
    }
    
    
    func setupButtons() {
        let buttons: [[String]] = [
            ["AC", "√", "%", "÷"],
            ["7", "8", "9", "×"],
            ["4", "5", "6", "-"],
            ["1", "2", "3", "+"],
            ["0", ".", "="]
        ]
        
        for (rowIndex, row) in buttons.enumerated() {
            let buttonStackView = UIStackView()
            buttonStackView.axis = .horizontal
            buttonStackView.alignment = .fill
            buttonStackView.distribution = rowIndex == 4 ? .fill : .fillEqually
            buttonStackView.spacing = 13
            
            for title in row {
                let button = UIButton()
                setupButton(button, title: title, row: rowIndex)
                buttonStackView.addArrangedSubview(button)
                
                if rowIndex == 4 {
                    if title == "0" {
                        button.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 0.5, constant: -((buttonStackView.spacing + 1) / 2)).isActive = true
                    } else {
                        button.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 0.25, constant: -((buttonStackView.spacing * 1.5) / 2)).isActive = true
                    }
                }
            }
            stackView.addArrangedSubview(buttonStackView)
        }
    }
    
    
    func setupButton(_ button: UIButton, title: String, row: Int) {
        let buttonHeight: CGFloat = 80.0
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 40)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 40
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        if title == "0" {
            button.contentHorizontalAlignment = .left
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
        if row == 0 && title != "÷" {
            button.backgroundColor = UIColor.lightGray
            button.setTitleColor(UIColor.black, for: .normal)
        }else if title != "0" && Int(title) != nil || title == "." {
            button.backgroundColor = UIColor.darkGray
        } else if title == "0" {
            button.backgroundColor = UIColor.darkGray
        } else {
            button.backgroundColor = UIColor.orange
        }
        buttonOriginalColors[button] = button.backgroundColor
    }
    
    
    @objc func buttonPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else {
            return
        }
        switch title {
        case "AC":
            firstNumber = nil
            secondNumber = nil
            operation = nil
            textField.text = "0"
        case "×":
            firstNumber = Double(textField.text!)
            operation = title
            shouldClearTextBeforeInserting = true
        case "√":
            if let number = Double(textField.text!) {
                let result = sqrt(number)
                textField.text = formatResult(result)
            }
        case "%":
            if let number = Double(textField.text!) {
                textField.text = (number / 100).clean
            }
        case "+", "-", "×", "÷":
            firstNumber = Double(textField.text!)
            operation = title
            shouldClearTextBeforeInserting = true
        case "=":
            calculateResult()
        case ".", "0"..."9":
            handleDigitOrDecimalPoint(title)
        default:
            break
        }
        highlightButton(sender)
    }
        
    
    func performOperation(operation: String, firstNumber: Double, secondNumber: Double) -> Double {
        switch operation {
        case "+":
            return firstNumber + secondNumber
        case "-":
            return firstNumber - secondNumber
        case "×":
            return firstNumber * secondNumber
        case "÷":
            return firstNumber / secondNumber
        default:
            fatalError("Неподдерживаемая операция")
        }
    }
    
    
    func calculateResult() {
        if let operation = operation,
           let firstNumber = self.firstNumber,
           let secondNumberString = textField.text?.replacingOccurrences(of: ",", with: "."),
           let secondNumber = Double(secondNumberString) {
            if operation == "÷" && secondNumber == 0 {
                showAlert(with: "Ошибка", message: "Деление на ноль недопустимо.")
                return
            }
            let result = performOperation(operation: operation, firstNumber: firstNumber, secondNumber: secondNumber)
            textField.text = formatResult(result)
            
            self.firstNumber = nil
            shouldClearTextBeforeInserting = true
            self.operation = nil
        }
    }
    
    
    func formatResult(_ result: Double) -> String {
        if abs(result) >= 1e6 || (abs(result) != 0 && abs(result) < 1e-4) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.positiveFormat = "0.###E0"
            formatter.exponentSymbol = "e"
            if let scientificFormatted = formatter.string(from: result as NSNumber) {
                return scientificFormatted
            }
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter.string(from: result as NSNumber) ?? "\(result)"
    }
    
    
    func showAlert(with title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self?.textField.text = "0"
                self?.firstNumber = nil
                self?.operation = nil
                self?.shouldClearTextBeforeInserting = true
            }
            alertController.addAction(okAction)
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func handleDigitOrDecimalPoint(_ title: String) {
        if shouldClearTextBeforeInserting {
            textField.text = ""
            shouldClearTextBeforeInserting = false
        }
        if let currentText = textField.text {
            if currentText == "0" {
                if title != "." {
                    textField.text = title
                } else {
                    textField.text = currentText + title
                }
            } else if title == "." && !currentText.contains(".") {
                textField.text = currentText + title
            } else if title != "." {
                textField.text = currentText + title
            }
            let fontSize = determineFontSizeForText(textField.text ?? "")
            textField.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    
    func determineFontSizeForText(_ text: String) -> CGFloat {
        let maxLength: Int = 6
        let currentLength = text.filter("0123456789".contains).count
        
        if currentLength > maxLength {
            return 60
        } else {
            return 80
        }
    }
    
    
    func highlightButton(_ button: UIButton) {
        guard let originalColor = buttonOriginalColors[button] else {
            print("Не удалось получить исходный цвет для кнопки")
            return
        }
        button.backgroundColor = UIColor.lightGray
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIView.animate(withDuration: 0.2) {
                button.backgroundColor = originalColor
            }
        }
    }
}


extension Double {
    var clean: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

