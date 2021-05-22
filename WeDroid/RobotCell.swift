//
//  RoboCell.swift
//  WeDroid
//
//  Created by v on 2021/5/19.
//

import UIKit

class RobotCell: UICollectionViewCell {
    private var item: RobotItem?

    var editingHandler: ((RobotItem) -> Void)?

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)

        return label
    }()

    lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .link.withAlphaComponent(0.8)

        return label
    }()

    lazy var appLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)

        return label
    }()

    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "more_item"), for: .normal)

        return button
    }()

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) { [weak self] in
                if let isHighlighted = self?.isHighlighted {
                    self?.transform = isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        layer.cornerRadius = 16
        backgroundColor = UIColor.systemBackground

        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: nameLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 24),
            NSLayoutConstraint(item: nameLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -64)
        ])

        appLabel.setContentHuggingPriority(.required, for: .horizontal)
        contentView.addSubview(appLabel)
        appLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: appLabel, attribute: .top, relatedBy: .equal, toItem: nameLabel, attribute: .bottom, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: appLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 24),
            NSLayoutConstraint(item: appLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -16)
        ])

        contentView.addSubview(urlLabel)
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: urlLabel, attribute: .centerY, relatedBy: .equal, toItem: appLabel, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: urlLabel, attribute: .left, relatedBy: .equal, toItem: appLabel, attribute: .right, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: urlLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -64)
        ])

        moreButton.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        contentView.addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: moreButton, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: moreButton, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: moreButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48),
            NSLayoutConstraint(item: moreButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(item: RobotItem) {
        self.item = item
        nameLabel.text = item.name
        appLabel.text = item.appName
        appLabel.textColor = item.appNameColor
        urlLabel.text = item.url.absoluteString
    }

    @objc func moreAction(_: Any) {
        guard let item = item else {
            return
        }
        
        editingHandler?(item)
    }
}

extension RobotCell {
    static let staticCell = RobotCell()

    class func systemLayoutSizeFitting(_ targetSize: CGSize, robotItem: RobotItem) -> CGSize {
        staticCell.frame = CGRect(origin: .zero, size: targetSize)
        staticCell.update(item: robotItem)
        
        return staticCell.systemLayoutSizeFitting(targetSize)
    }
}
