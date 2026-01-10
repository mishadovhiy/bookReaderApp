//
//  String.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 10.01.2026.
//

import UIKit

extension UIFont {
    func size(text: String, maxWidth: CGFloat) -> CGSize {
        let constraint = CGSize(
            width: maxWidth,
            height: .greatestFiniteMagnitude
        )
        
        let rect = (text as NSString).boundingRect(
            with: constraint,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: self],
            context: nil
        )
        
        return CGSize(
            width: ceil(rect.width),
            height: ceil(rect.height)
        )
    }
}
