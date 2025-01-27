import SwiftUI

struct Chip: View {
    private let text: String
    
    private var fontWeight: Font.Weight? = .semibold
    private var leftComponent: (() -> AnyView?)? = nil
    private var rightComponent: (() -> AnyView)? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            if let leftComponent = self.leftComponent {
                leftComponent()
            }

            Text(text.uppercased())
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(foregroundColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            
            if let rightComponent = self.rightComponent {
                rightComponent()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(.clear)
                .overlay {
                    Capsule()
                        .background(backgroundColor)
                        .clipShape(Capsule())
                }
        }
        .contentShape(Capsule())
    }
    
    // Colors adapt to the color scheme
    private var foregroundColor: Color {
        // Text color: #74c0fc for dark mode
        self.colorScheme == .light ? Color(red: 250/255, green: 250/255, blue: 251/255) :
            Color(red: 116/255, green: 192/255, blue: 252/255)
    }
    
    private var backgroundColor: Color {
        self.colorScheme == .dark
            ? Color(red: 34/255, green: 139/255, blue: 230/255).opacity(0.15) // Light mode: #228be6
            : Color(red: 34/255, green: 139/255, blue: 230/255) // Dark mode: #74c0fc
    }
}

#Preview {
    Chip(text: "into the storm")
}

extension Chip {
    /*
    func highlightColor(_ color: Color) -> Self {
        var copy = self
        copy.highlight = color
        return copy
    }
    
    func softColor(_ color: Color) -> Self {
        var copy = self
        copy.soft = color
        return copy
    }*/
    
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
}

