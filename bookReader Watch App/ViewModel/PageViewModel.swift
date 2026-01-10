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
    
    @Published var lastVisibleParagraph: String?
    @Published var scrollTo: String?
    @Published var paragraphs: [ParagraphText] = []
    
    init(bookID: String, chapter: BookModel.Chapters) {
        self.bookID = bookID
        self.chapter = chapter
    }
    
    let textFontSize: UIFont = .systemFont(ofSize: 18, weight: .regular)
    private let highlightedColor: UIColor = .red
    
    func reloadAttributedString(tagPosition: [TagPositionList]) {
        self.paragraphs = chapter.paragraphs.compactMap({ paragraph in
            let keys = tagPosition.filter({
                ![
                    $0.paragraphID == paragraph.id,
                    $0.chapterID == chapter.id
                ].contains(false)
            })
            let attribute = self.attributeText(
                for: paragraph,
                highlightedKeys: keys)
            
            return .init(paragraphID: paragraph.id,
                         attributedString: attribute)
        })
    }

    func didTapWord(parapgaphID: String,
                    text: String,
                    viewWidth: CGFloat,
                    tapPosition: CGPoint,
                    tagPosition: Binding<[TagPositionList]>,
                    db: CoreDataService) {
        let tappedInx = tappedWordInx(tapPosition, text: text, maxWidth: viewWidth)
        if let tappedInx {
            let tags = tagPosition.wrappedValue.filter({
                parapgaphID == $0.paragraphID
            })
            if tags.contains(where: {
                $0.positionInText == tappedInx
            }) {
                tagPosition.wrappedValue.filter({
                    $0.positionInText == tappedInx
                }).forEach {
                    db.context.delete($0)
                }
                tagPosition.wrappedValue.removeAll(where: {
                    $0.positionInText == tappedInx
                })
            } else {
                let newTag: TagPositionList = .init(context: db.context)
                newTag.bookID = bookID
                newTag.chapterID = chapter.id
                newTag.paragraphID = parapgaphID
                newTag.positionInText = Int64(tappedInx)
                tagPosition.wrappedValue.append(newTag)
            }
        }
    }
    
    private func wordWidth(_ word: String) -> CGFloat {
        (word as NSString).size(withAttributes: [.font: textFontSize]).width
    }
    
    private func tappedWordInx(
        _ point: CGPoint,
        text: String,
        maxWidth: CGFloat
    ) -> Int? {

        let splittedText = text.split(whereSeparator: \.isWhitespace)
        let spaceWidth = wordWidth(" ")
        var loopOffset: CGPoint = .zero
        
        for i in 0..<splittedText.count {
            let word = splittedText[i]
            let wordSize: CGSize = .init(
                width: wordWidth(String(word)),
                height: textFontSize.lineHeight)

            if loopOffset.x + wordSize.width > maxWidth {
                loopOffset.x = 0
                loopOffset.y += textFontSize.lineHeight
            }

            let wordRect = CGRect(origin: loopOffset,
                                  size: wordSize)
            if wordRect.contains(point) {
                return i
            }
            loopOffset.x += wordSize.width + spaceWidth
        }

        return nil
    }
    
    private func attributeText(
        for paragraph: BookModel.Chapters.Paragraphs,
        highlightedKeys: [TagPositionList]
    ) -> NSAttributedString {
        
        let splittedText = paragraph.content.split(separator: " ")
        let attributedString: NSMutableAttributedString = .init()

        for i in 0..<splittedText.count {
            let item = splittedText[i]
            let higlight = highlightedKeys.contains(where: {
                $0.positionInText == i
            })

            attributedString.append(.init(string: String(item) + " ", attributes: higlight ? [
                .backgroundColor: highlightedColor
            ] : [:]))
        }
        return attributedString
    }
}

extension PageViewModel {
    struct ParagraphText {
        let paragraphID: String
        let attributedString: NSAttributedString
    }
}
