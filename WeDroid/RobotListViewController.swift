//
//  RoboListViewController.swift
//  WeDroid
//
//  Created by v on 2021/5/19.
//

import UIKit

class RoboListViewController: RBViewController {
    var roboList = [RobotItem]()

    lazy var listView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16

        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.register(RobotCell.self, forCellWithReuseIdentifier: NSStringFromClass(RobotCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRoboAction(_:)))

        view.addSubview(listView)
        listView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: listView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: listView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: listView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: listView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        ])

        DispatchQueue.global().async { [weak self] in
            let robots = Storage.shared.getRobotList()
            if robots.count > 0 {
                DispatchQueue.main.async {
                    self?.roboList = robots
                    self?.listView.reloadData()
                }
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        listView.collectionViewLayout.invalidateLayout()
    }

    @objc func addRoboAction(_: Any) {
        let vc = RobotConfigurationController()
        vc.completionHandler = { [weak self] (item) in
            self?.roboList.append(item)
            self?.listView.reloadData()
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    func moreRobotAction(_ item: RobotItem) {
        let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert
        let alert = UIAlertController(title: item.name, message: item.url.absoluteString, preferredStyle: style)
        alert.addAction(UIAlertAction(title: NSLocalizedString("编辑", comment: ""), style: .default, handler: { [weak self] (_) in
            self?.editRobot(item)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("删除", comment: ""), style: .destructive, handler: { [weak self] (_) in
            self?.removeRobot(item)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel))

        self.present(alert, animated: true)
    }

    func editRobot(_ item: RobotItem) {
        let vc = RobotConfigurationController()
        vc.robotItem = item
        vc.completionHandler = { [weak self] (new) in
            self?.updateRobot(from: item, to: new)
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    func updateRobot(from old: RobotItem, to new: RobotItem) {
        guard let index = roboList.firstIndex(where: { ($0.name == old.name) && ($0.url == old.url) }) else {
            return
        }

        roboList.remove(at: index)
        roboList.insert(new, at: index)
        listView.reloadData()
    }

    func removeRobot(_ item: RobotItem) {
        guard let index = roboList.firstIndex(where: { ($0.name == item.name) && ($0.url == item.url) }) else {
            return
        }

        roboList.remove(at: index)
        listView.reloadData()

        item.remove()
    }
}

extension RoboListViewController: UICollectionViewDelegateFlowLayout,
                                  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roboList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(RobotCell.self), for: indexPath) as! RobotCell
        cell.update(item: roboList[indexPath.row])
        cell.editingHandler = { [weak self] (item) in
            self?.moreRobotAction(item)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        let targetSize = CGSize(width: width, height: 1000000000)

        var size = RobotCell.systemLayoutSizeFitting(targetSize, robotItem: roboList[indexPath.row])
        size.width = width

        return size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let item = roboList[indexPath.row]

        let vc = PostViewController()
        vc.robotItem = item
        navigationController?.pushViewController(vc, animated: true)
    }
}
