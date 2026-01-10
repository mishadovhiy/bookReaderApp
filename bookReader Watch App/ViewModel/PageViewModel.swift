//
//  PageViewModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 10.01.2026.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import CoreData

class PageViewModel: ObservableObject {
    
    let bookID: String
    let chapter: BookModel.Chapters
    
    init(bookID: String, chapter: BookModel.Chapters) {
        self.bookID = bookID
        self.chapter = chapter
    }
    
    let textFontSize: UIFont = .systemFont(ofSize: 14, weight: .regular)
    
    @Published var lastScrollHolder: String?
    @Published var scrollTo: String?
    @Published var contents: [(String, NSAttributedString)] = []
    
    func reloadAttributedString(backGroundsAt: [TagPositionList]) {
        var contents = contents
        contents.removeAll()
        self.chapter.paragraphs.forEach { paragraph in
            let attributes: NSMutableAttributedString = .init()
            let array = paragraph.content.split(separator: " ")

            let key = backGroundsAt.filter({
                ![
                    $0.paragraphID == paragraph.id, $0.chapterID == chapter.id
                ].contains(false)
            })
            for i in 0..<array.count {
                let item = array[i]
                let higlight = key.contains(where: {
                    $0.positionInText == i
                })

                attributes.append(.init(string: String(item) + " ", attributes: higlight ? [
                    .backgroundColor: UIColor.red
                ] : [:]))
            }

            contents.append((paragraph.id, attributes))
        }
        self.contents = contents
    }

    
    func didTapWord(parapgaphID: String, text: String, viewWidth: CGFloat, tapPosition: CGPoint, backGroundsAt: Binding<[TagPositionList]>, db: CoreDataService) {
        let text = self.textAtPoint(tapPosition, text: text, font: textFontSize, maxWidth: viewWidth)
        if let text {
            let values = backGroundsAt.wrappedValue.filter({
                parapgaphID == $0.paragraphID
            })
            if values.contains(where: {
                $0.positionInText == text
            }) {
                let toDelete = backGroundsAt.wrappedValue.filter({
                    $0.positionInText == text
                })
                toDelete.forEach {
                    db.contexts.delete($0)
                }
                backGroundsAt.wrappedValue.removeAll(where: {
                    $0.positionInText == text
                })
            } else {
                let new: TagPositionList = .init(context: db.contexts)
                new.bookID = bookID
                new.chapterID = chapter.id
                new.paragraphID = parapgaphID
                new.positionInText = Int64(text)
                backGroundsAt.wrappedValue.append(new)
            }
        }
    }
    
    func wordWidth(_ word: String, font: UIFont) -> CGFloat {
        (word as NSString).size(withAttributes: [.font: font]).width
    }
    
    func textAtPoint(
        _ point: CGPoint,
        text: String,
        font: UIFont,
        maxWidth: CGFloat
    ) -> Int? {

        let words = text.split(whereSeparator: \.isWhitespace)
        let spaceWidth = wordWidth(" ", font: font)
        let lineHeight = font.lineHeight

        var x: CGFloat = 0
        var y: CGFloat = 0

        for i in 0..<words.count {
            let word = words[i]
            let wordStr = String(word)
            let width = wordWidth(wordStr, font: font)

            if x + width > maxWidth {
                x = 0
                y += lineHeight
            }

            let rect = CGRect(
                x: x,
                y: y,
                width: width,
                height: lineHeight
            )

            if rect.contains(point) {
                return i
            }

            x += width + spaceWidth
        }

        return nil
    }
}
