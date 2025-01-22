import SwiftUI

struct Chip: View {
    private let text: String
    
    private var highlight = Color.rgba(12, 93, 86)
    private var soft = Color.rgba(94, 234, 212)
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

            
            Text(text)
                .font(.caption)
                .foregroundColor(self.colorScheme == .dark ? self.soft : self.highlight)
                .fontWeight(self.fontWeight)
                .id(text)
            
            if let rightComponent = self.rightComponent {
                rightComponent()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(/*self.colorScheme == .dark ? self.highlight : self.soft.opacity(0.3)*/ .clear)
                .overlay {
                    Capsule()
                        .stroke(self.colorScheme == .dark ? self.soft : self.highlight, lineWidth: 0.3)
                        .padding(0.3)
                }
        }
        .contentShape(Capsule())
    }
}

#Preview {
    Chip(text: "into the storm")
}

extension Chip {
    func highlightColor(_ color: Color) -> Self {
        var copy = self
        copy.highlight = color
        return copy
    }
    
    func softColor(_ color: Color) -> Self {
        var copy = self
        copy.soft = color
        return copy
    }
    
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

