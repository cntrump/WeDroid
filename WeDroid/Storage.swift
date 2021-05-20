//
//  Storage.swift
//  WeDroid
//
//  Created by v on 2021/5/20.
//

import Foundation

class Storage {
    private let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

    lazy var robotsDirectory: URL = {
        let directory = applicationSupportDirectory.appendingPathComponent("robots")
        if !FileManager.default.fileExists(atPath: directory.path) {
            _ = try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        return directory
    }()

    class var shared: Storage {
        return Storage()
    }

    func getRobotList() -> [RobotItem] {
        var robots = [RobotItem]()

        guard let enumerator = FileManager.default.enumerator(atPath: robotsDirectory.path) else {
            return robots
        }

        while let file = enumerator.nextObject() as? String {
            let path = robotsDirectory.appendingPathComponent(file)
            if file.hasSuffix(".json"),
               let data = try? Data(contentsOf: path),
               data.count > 0,
               var item = try? JSONDecoder().decode(RobotItem.self, from: data) {
                item.path = path
                robots.append(item)
            }
        }

        return robots
    }

    func getNewFile() -> URL {
        let file = "\(Int(Date().timeIntervalSince1970)).json"

        return robotsDirectory.appendingPathComponent(file)
    }
}
