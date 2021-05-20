//
//  RobotItem.swift
//  WeDroid
//
//  Created by v on 2021/5/19.
//

import Foundation

struct RobotItem: Codable {
    var name: String
    var url: URL

    var path: URL?

    enum CodingKeys: String, CodingKey {
        case name
        case url
    }

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }

    mutating func save() {
        guard let data = try? JSONEncoder().encode(self) else {
            return
        }

        if path == nil {
            path = Storage.shared.getNewFile()
        }

        _ = try? data.write(to: path!)
    }

    func remove() {
        guard let path = path else {
            return
        }

        _ = try? FileManager.default.removeItem(atPath: path.path)
    }
}
