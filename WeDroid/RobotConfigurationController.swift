//
//  RobotConfigurationController.swift
//  WeDroid
//
//  Created by v on 2021/5/19.
//

import UIKit

class RBTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor

        backgroundColor = .systemBackground

        autocorrectionType = .no
        autocapitalizationType = .none
        spellCheckingType = .no
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect = rect.insetBy(dx: 8, dy: 8)

        return rect
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect = rect.insetBy(dx: 8, dy: 8)

        return rect
    }
}

class RobotConfigurationController: RBViewController {
    var robotItem: RobotItem?
    var completionHandler: ((RobotItem)-> Void)?

    lazy var nameTextfield = RBTextField()
    lazy var urlTextField = RBTextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = robotItem != nil ? NSLocalizedString("编辑机器人", comment: "") : NSLocalizedString("添加机器人", comment: "")

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("保存", comment: ""),
                                                            style: .plain, target: self, action: #selector(saveAction(_:)))

        nameTextfield.placeholder = NSLocalizedString("机器人名称", comment: "")
        nameTextfield.text = robotItem?.name
        view.addSubview(nameTextfield)
        nameTextfield.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: nameTextfield, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: nameTextfield, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: nameTextfield, attribute: .right, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: nameTextfield, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35)
        ])

        urlTextField.placeholder = NSLocalizedString("机器人的 URL", comment: "")
        urlTextField.textColor = .link
        urlTextField.text = robotItem?.url.absoluteString
        view.addSubview(urlTextField)

        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: urlTextField, attribute: .top, relatedBy: .equal, toItem: nameTextfield, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: urlTextField, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: urlTextField, attribute: .right, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: urlTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35)
        ])
    }

    @objc func saveAction(_: Any) {
        defer {
            navigationController?.popViewController(animated: true)
        }

        guard var urlString = urlTextField.text else {
            return
        }

        if urlString.count > 0, !urlString.hasPrefix("http") {
            urlString = "https://" + urlString
        }

        guard let name = nameTextfield.text,
           let url = URL(string: urlString),
           name.count > 0 else {
            return
        }

        if robotItem == nil {
            robotItem = RobotItem(name: name, url: url)
        } else {
            robotItem?.name = name
            robotItem?.url = url
        }

        robotItem?.save()
        completionHandler?(robotItem!)
    }
}
