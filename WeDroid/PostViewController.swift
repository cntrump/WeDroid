//
//  PostViewController.swift
//  WeDroid
//
//  Created by v on 2021/5/19.
//

import UIKit

struct ErrModel: Decodable {
    var errcode: Int?
    var errmsg: String?

    var code: Int?
    var msg: String?

    func getCode() -> Int {
        if let code = code {
            return code
        }

        if let code = errcode {
            return code
        }

        return 0
    }

    func getMsg() -> String? {
        if let msg = msg {
            return msg
        }

        if let msg = errmsg {
            return msg
        }

        return nil
    }
}

class PostViewController: RBViewController {
    let sendBarButtonItem = UIBarButtonItem(image: UIImage(named: "send_item"), style: .plain, target: self, action: #selector(sendAction(_:)))
    var robotItem: RobotItem?
    lazy var textViewBottomConstraint = NSLayoutConstraint(item: textView, attribute: .bottom,
                                                           relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)

    lazy var textView: UITextView = {
        let textView = UITextView(frame: view.bounds)

        return textView
    }()

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = robotItem?.name
        navigationItem.rightBarButtonItem = sendBarButtonItem

        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            textViewBottomConstraint,
            NSLayoutConstraint(item: textView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChangeAction(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        textView.becomeFirstResponder()
    }

    @objc func sendAction(_: Any) {
        guard var text = textView.text, text.count > 0 else {
            return
        }

        sendBarButtonItem.isEnabled = false

        text = MDPreprocessor(text: text).process()

        guard let request = robotItem?.request(withText: text) else {
            sendBarButtonItem.isEnabled = true
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            let msg = NSLocalizedString("错误码：\((error as NSError).code)", comment: "")
                            let alert = UIAlertController(title: NSLocalizedString("出错了", comment: ""), message: msg, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("好的", comment: ""), style: .default))
                            self?.present(alert, animated: true)
                        } else {
                            if let data = data,
                               let errModel = try? JSONDecoder().decode(ErrModel.self, from: data) {
                                if errModel.getCode() == 0 {
                                    self?.showSuccess()
                                } else {
                                    self?.showError(errModel)
                                }
                            }
                        }

                        self?.sendBarButtonItem.isEnabled = true
                    }
                }

        task.resume()
    }

    func showSuccess() {
        let title = NSLocalizedString("完成", comment: "")
        let alert = UIAlertController(title: title, message: NSLocalizedString("发送成功", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("清空编辑器", comment: ""), style: .default) { [weak self] (_) in
            self?.textView.text = ""
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("好的", comment: ""), style: .default))
        present(alert, animated: true)
    }

    func showError(_ err: ErrModel) {
        guard err.getCode() != 0, let errmsg = err.getMsg() else {
            return
        }

        let title = NSLocalizedString("出错了", comment: "")
        let alert = UIAlertController(title: title, message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("好的", comment: ""), style: .default))
        present(alert, animated: true)
    }
}

extension PostViewController {
    @objc func keyboardFrameWillChangeAction(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        let kbinfo = KeyboardUserInfo(userInfo: userInfo)
        let rect = view.convert(kbinfo.frameEnd, from: nil)
        textViewBottomConstraint.constant = -rect.height
        textView.setNeedsUpdateConstraints()

        kbinfo.animate { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}
