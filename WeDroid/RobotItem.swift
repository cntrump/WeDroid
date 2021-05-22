//
//  RobotItem.swift
//  WeDroid
//
//  Created by v on 2021/5/19.
//

import UIKit
import CryptoKit

struct RobotItem: Codable {
    var name: String
    var url: URL
    var token: String? // 签名 key

    var path: URL?

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case token
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

extension String {
    static let lark = "larksuite.com"
    static let dingtalk = "dingtalk.com"
    static let wechat = "weixin.qq.com"
}

extension RobotItem {
    private func getToken() -> String? {
        guard let host = url.host,
              (host.hasSuffix(.lark) || host.hasSuffix(.dingtalk)),
              let token = token else {
            return nil
        }

        return token
    }

    //
    // https://www.larksuite.com/hc/en-US/articles/360048487736#1.1.1%20Security%20settings
    // https://developers.dingtalk.com/document/app/custom-robot-access
    //
    private func genSign(withTimestamp timestamp: Int) -> String? {
        guard let token = getToken(),
              let tokenData = token.data(using: .utf8),
              let host = url.host else {
            return nil
        }

        var signature: Data?

        if host.hasSuffix(.dingtalk) {
            let key = SymmetricKey(data: tokenData)
            let string = "\(timestamp)" + "\n" + token
            signature = Data(HMAC<SHA256>.authenticationCode(for: string.data(using: .utf8)!, using: key))
        } else if host.hasSuffix(.lark) {
            let string = "\(timestamp)" + "\n" + token
            let key = SymmetricKey(data: string.data(using: .utf8)!)
            signature = Data(HMAC<SHA256>.authenticationCode(for: Data(), using: key))
        }

        return signature?.base64EncodedString(options: .lineLength64Characters)
    }

    private var isValidHost: Bool {
        guard let host = url.host else {
            return false
        }

        return host.hasSuffix(.lark) ||
            host.hasSuffix(.dingtalk) ||
            host.hasSuffix(.wechat)
    }

    func request(withText text: String) -> URLRequest? {
        guard var uc = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = uc.host,
              isValidHost else {
            return nil
        }


        var body = [String: Any]()

        if host.hasSuffix(.dingtalk) {
            let timestamp = Int(Date().timeIntervalSince1970 * 1000.0)
            let signature = genSign(withTimestamp: timestamp)
            var queryItems = uc.queryItems
            queryItems?.append(URLQueryItem(name: "timestamp", value: "\(timestamp)"))
            queryItems?.append(URLQueryItem(name: "sign", value: signature))
            uc.queryItems = queryItems
            body["msgtype"] = "markdown"
            body["markdown"] = [
                "title": text.prefix(16),
                "text": text
            ]
        } else if host.hasSuffix(.lark) {
            let timestamp = Int(Date().timeIntervalSince1970)
            let signature = genSign(withTimestamp: timestamp)
            body["timestamp"] = "\(timestamp)"
            body["sign"] = signature
            body["msg_type"] = "text"
            body["content"] = [
                "text": text
            ]
        } else if host.hasSuffix(.wechat) {
            body["msgtype"] = "markdown"
            body["markdown"] = [
                "content": text
            ]
        }

        guard JSONSerialization.isValidJSONObject(body),
              let httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
              let url = uc.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(httpBody.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = httpBody

        return request
    }
}

extension RobotItem {
    var appName: String {
        guard let host = url.host else {
            return ""
        }

        if host.hasSuffix(.lark) {
            return NSLocalizedString("飞书", comment: "")
        }

        if host.hasSuffix(.dingtalk) {
            return NSLocalizedString("钉钉", comment: "")
        }

        if host.hasSuffix(.wechat) {
            return NSLocalizedString("企业微信", comment: "")
        }

        return ""
    }

    var appNameColor: UIColor {
        var color = UIColor.systemGray

        guard let host = url.host else {
            return color
        }

        if host.hasSuffix(.lark) {
            color = .systemTeal
        }

        if host.hasSuffix(.dingtalk) {
            color = .systemOrange
        }

        if host.hasSuffix(.wechat) {
            color = .systemBlue
        }

        return color
    }
}
