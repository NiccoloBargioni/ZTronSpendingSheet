import SwiftUI

struct Chip: View {
    private let text: String
    
    private var fontWeight: Font.Weight? = .semibold
    private var leftComponent: (() -> AnyView?)? = nil
    private var rightComponent: (() -> AnyView)? = nil
    
    
    internal var tintLight: Color? = nil
    internal var tintDark: Color? = nil
    
    internal var materialLight: Color? = nil
    internal var materialDark: Color? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let leftComponent = self.leftComponent {
                leftComponent()
                    .tint(
                        self.colorScheme == .light ? self.tintLight ?? self.foregroundColor : self.tintDark ?? self.foregroundColor
                    )
            }

            Text(text.uppercased())
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(
                    self.colorScheme == .light ? self.tintLight ?? self.foregroundColor : self.tintDark ?? self.foregroundColor
                )
            
            if let rightComponent = self.rightComponent {
                rightComponent()
                    .tint(
                        self.colorScheme == .light ? self.tintLight ?? self.foregroundColor : self.tintDark ?? self.foregroundColor
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(.clear)
                .overlay {
                    Capsule()
                        .fill(self.colorScheme == .light ? self.materialLight ?? self.backgroundColor : self.materialDark ?? self.backgroundColor
)
                        .clipShape(Capsule())
                }
        }
        .contentShape(Capsule())
    }
    
    private var foregroundColor: Color {
        self.colorScheme == .light ? Color(red: 250/255, green: 250/255, blue: 251/255) :
            Color(red: 116/255, green: 192/255, blue: 252/255)
    }
    
    private var backgroundColor: Color {
        self.colorScheme == .dark
            ? Color(red: 34/255, green: 139/255, blue: 230/255).opacity(0.15)
            : Color(red: 34/255, green: 139/255, blue: 230/255)
    }
}

#Preview {
    Chip(text: "into the storm")
}

extension Chip {

    func fontWeight(_ weight: Font.Weight?) -> Self {
        var copy = self
        copy.fontWeight = weight
        return copy
    }
    
    func rightComponent(_ rightComponent: @escaping () -> AnyView) -> Self {
        var copy = self
        copy.rightComponent = rightComponent
        return copy
    }
    
    func leftComponent(_ leftComponent: @escaping () -> AnyView) -> Self {
        var copy = self
        copy.leftComponent = leftComponent
        return copy
    }
    
    
    func tint(light: Color, dark: Color) -> Self {
        var copy = self
        copy.tintLight = light
        copy.tintDark = dark
        return copy
    }
    
    func material(light: Color, dark: Color) -> Self {
        var copy = self
        copy.materialLight = light
        copy.materialDark = dark
        return copy
    }
    
    
}

