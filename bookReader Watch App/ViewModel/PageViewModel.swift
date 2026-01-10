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
    
    @Published var lastVisibleParagraph: String?
    @Published var scrollTo: String?
    @Published var contents: [(String, NSAttributedString)] = []
    
    #warning("refactor")
    func reloadAttributedString(tagPosition: [TagPositionList]) {
        var contents = contents
        contents.removeAll()
        self.chapter.paragraphs.forEach { paragraph in
            let attributes: NSMutableAttributedString = .init()
            let array = paragraph.content.split(separator: " ")

            let key = tagPosition.filter({
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

    #warning("refactor")
    func didTapWord(parapgaphID: String, text: String, viewWidth: CGFloat, tapPosition: CGPoint, tagPosition: Binding<[TagPositionList]>, db: CoreDataService) {
        let wordIndexTapped = tapWordInx(tapPosition, text: text, maxWidth: viewWidth)
        if let wordIndexTapped {
            let values = tagPosition.wrappedValue.filter({
                parapgaphID == $0.paragraphID
            })
            if values.contains(where: {
                $0.positionInText == wordIndexTapped
            }) {
                let toDelete = tagPosition.wrappedValue.filter({
                    $0.positionInText == wordIndexTapped
                })
                toDelete.forEach {
                    db.context.delete($0)
                }
                tagPosition.wrappedValue.removeAll(where: {
                    $0.positionInText == wordIndexTapped
                })
            } else {
                let new: TagPositionList = .init(context: db.context)
                new.bookID = bookID
                new.chapterID = chapter.id
                new.paragraphID = parapgaphID
                new.positionInText = Int64(wordIndexTapped)
                tagPosition.wrappedValue.append(new)
            }
        }
    }
    
    func wordWidth(_ word: String) -> CGFloat {
        (word as NSString).size(withAttributes: [.font: textFontSize]).width
    }
    
    private func tapWordInx(
        _ point: CGPoint,
        text: String,
        maxWidth: CGFloat
    ) -> Int? {

        let chapterWords = text.split(whereSeparator: \.isWhitespace)
        let spaceWidth = wordWidth(" ")

        var x: CGFloat = 0
        var y: CGFloat = 0

        for i in 0..<chapterWords.count {
            let word = chapterWords[i]
            let wordWidth = wordWidth(String(word))

            if x + wordWidth > maxWidth {
                x = 0
                y += textFontSize.lineHeight
            }

            let wordRect = CGRect(
                x: x,
                y: y,
                width: wordWidth,
                height: textFontSize.lineHeight
            )

            if wordRect.contains(point) {
                return i
            }

            x += wordWidth + spaceWidth
        }

        return nil
    }
}
