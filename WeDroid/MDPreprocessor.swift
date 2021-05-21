//
//  MDPreprocessor.swift
//  WeDroid
//
//  Created by v on 2021/5/21.
//

import UIKit

class MDPreprocessor {
    private lazy var autolinkRegexpr = try? NSRegularExpression(pattern: "(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]",
                                                                options: .caseInsensitive)
    var text: String

    init(text: String) {
        self.text = text
    }

    func process() -> String {
        let string = NSMutableString(string: text)
        let maxRange = NSRange(location: 0, length: string.length)

        guard var matches = autolinkRegexpr?.matches(in: text,
                                                     options: .reportCompletion,
                                                     range: maxRange),
              matches.count > 0 else {
            return text
        }

        matches.reverse()

        for result in matches {
            let range = result.range
            let subString = (text as NSString).substring(with: range) as NSString
            let loc = range.location
            var isAutolink = loc == 0
            if loc > 0 {
                let prev = string.substring(with: string.rangeOfComposedCharacterSequence(at: loc - 1))
                if prev.elementsEqual(" ") || prev.elementsEqual("\n") {
                    isAutolink = true
                }
            }

            if isAutolink {
                string.replaceCharacters(in: range, with: "[\(subString)](\(subString))")
            }
        }

        return String(string)
    }
}
