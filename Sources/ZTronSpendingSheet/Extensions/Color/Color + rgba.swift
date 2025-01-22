import SwiftUI

extension SwiftUI.Color {
    static func rgba(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1.0) -> SwiftUI.Color {
        assert(r >= 0 && r <= 255)
        assert(g >= 0 && g <= 255)
        assert(b >= 0 && b <= 255)
        assert(a >= 0 && a <= 1)
        
        return SwiftUI.Color(cgColor:
            CGColor(
                red: CGFloat(r)/255.0,
                green: CGFloat(g)/255.0,
                blue: CGFloat(b)/255.0,
                alpha: a
            )
        )
    }
}

