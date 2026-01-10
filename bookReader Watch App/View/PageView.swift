//
//  PageView.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import SwiftUI

struct PageView: View {
    let bookID: String
    let chapter: BookModel.Chapters
    @Binding var firstAppLaunched: Bool
    @Binding var lastScrollID: String?
    @State private var scrollTo: String?
    @State var contents: [(String, NSAttributedString)] = []
    @Binding var backGroundsAt: [String: [Int]]// = ["p-001-001": [6]]
    func reloadAttributedString() {
        var contents = contents
        contents.removeAll()
        self.chapter.paragraphs.forEach { paragraph in
            let attributes: NSMutableAttributedString = .init()
            let array = paragraph.content.split(separator: " ")
            let key = self.backGroundsAt[paragraph.id]
            for i in 0..<array.count {
                let item = array[i]
                let higlight = key?.contains(i) ?? false

                attributes.append(.init(string: String(item) + " ", attributes: higlight ? [
                    .backgroundColor: UIColor.red
                ] : [:]))
            }

            contents.append((paragraph.id, attributes))
        }
        self.contents = contents
    }
    var body: some View {
        ScrollView(.vertical) {
            ScrollViewReader { scrollProxy in
                LazyVStack(spacing: 10, content: {
                    Text(chapter.title)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    ForEach(contents, id: \.0) { content in
                        Text(.init(content.1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.leading)
                            .id(content.0)
                            .onDisappear {
                                lastScrollID = content.0
                                print(content.0, " bjhknlm ")
                            }
                            .overlay {
                                GeometryReader { proxy in
                                    Color.white.opacity(0.01)
                                        .onTapGesture { point in
                                            print(point, " egrsfdsa")
                                            let text = self.textAtPoint(point, text: content.1.string, font: .systemFont(ofSize: 12), maxWidth: proxy.size.width)
                                            if let text {
                                                var values = self.backGroundsAt[content.0] ?? []
                                                if values.contains(text) {
                                                    values.removeAll(where: {
                                                        $0 == text
                                                    })
                                                } else {
                                                    values.append(text)
                                                }
                                                self.backGroundsAt.updateValue(values, forKey: content.0)
                                            }
                                            print(text)
                                        }
                                }
                                
                            }
                    }
                    //                    ForEach(chapter.paragraphs, id: \.id) { paragraph in
                    //                        Text(paragraph.content)
                    //                            .frame(maxWidth: .infinity, alignment: .leading)
                    //                            .multilineTextAlignment(.leading)
                    //                            .id(paragraph.id)
                    //                            .onDisappear {
                    //                                lastScrollID = paragraph.id
                    //                                print(paragraph.id, " bjhknlm ")
                    //                            }
                    //                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: scrollTo) { newValue in
                    if let scrollTo {
                        scrollProxy.scrollTo(scrollTo)
                        self.scrollTo = nil
                    }
                }
            }
        }
        .onChange(of: backGroundsAt) { newValue in
            reloadAttributedString()
        }
        .onAppear {
            print("appsfdfds")
            reloadAttributedString()
            if let lastScrollID, !firstAppLaunched, !lastScrollID.isEmpty {
                scrollTo = lastScrollID
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
            // wrap line
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
//
//#Preview {
//    PageView(bookID: "001", chapter: .demo)
//}
