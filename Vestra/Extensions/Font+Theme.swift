//
//  Font+Theme.swift
//  Vestra
//
//  Three font roles, all using Titan One.
//  Same API as before — swap the font name here to change it everywhere at once.
//

import SwiftUI

extension Font {
    static let theme = ThemeFonts()

    struct ThemeFonts {

        // MARK: Display — large titles, hero numbers
        func display(_ size: CGFloat, weight: Font.Weight = .black) -> Font {
            Font.custom("ABeeZee-Regular", size: size)
        }

        // MARK: UI — body, labels, buttons
        func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.custom("ABeeZee-Regular", size: size)
        }

        // MARK: Mono — ALL CAPS metadata, numerics
        func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.custom("ABeeZee-Regular", size: size)
        }
    }
}
