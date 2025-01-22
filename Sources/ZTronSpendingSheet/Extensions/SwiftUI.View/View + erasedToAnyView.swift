import SwiftUI

internal extension View {
    func erasedToAnyView() -> AnyView {
        return AnyView(self)
    }
}
