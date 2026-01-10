//
//  BackgroundTextViewModifier.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 10.01.2026.
//

import SwiftUI

struct BackgroundTextViewModifier: ViewModifier {
    let text: String
    let textHelperOverlaySizes: EdgeInsets
    @Binding var safeArea: EdgeInsets
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            safeArea = proxy.safeAreaInsets
                        }
                }
            }
            .background(content: {
                Text(text)
                    .font(.system(size: 9))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.secondary)
            })

            .overlay(content: {
                VStack {
                    Color.black
                        .frame(height: textHelperOverlaySizes.top)
                    Spacer()
                    Color.black
                        .frame(height: textHelperOverlaySizes.bottom)
                        .offset(y: safeArea.bottom / 2)
                }
                .disabled(true)
            })
    }
}
