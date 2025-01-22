import SwiftUI

internal struct SpendingTopbarItemView: View {
    @ObservedObject private var tool: SpendingSheetTopbarItem
    private let isActive: Bool
    private var shouldHighlightText: Bool = false
    private var onRarityChange: @Sendable (_: Rarity) -> Void
    internal var allowChangeToRarity: (@MainActor (_: SpendingSheetTopbarItem, _: Rarity) -> Bool)?
    
    internal init(
        tool: SpendingSheetTopbarItem,
        isActive: Bool,
        onRarityChange: @escaping @Sendable (_: Rarity) -> Void,
        allowChangeToRarity: (@Sendable (_: SpendingSheetTopbarItem, _: Rarity) -> Bool)? = nil
    ) {
        self._tool = ObservedObject(wrappedValue: tool)
        self.isActive = isActive
        self.onRarityChange = onRarityChange
        self.allowChangeToRarity = allowChangeToRarity
    }

    internal var body: some View {
        // MARK: - <= IOS 15.0
        if #unavailable(iOS 16.0) {
            VStack {
                TopbarItemShopWindow(icon: tool.getIcon(), isActive: isActive)
                    .glowColor(Color(self.tool.getRarity().rawValue, bundle: .module))
              Text(tool.getName().fromLocalized())
              .fontWeight(
                isActive ? .bold : .regular
              )
              .foregroundColor(Color(UIColor.label))
              .font(.caption2)
              .frame(minWidth: TopbarItemShopWindow.radius, idealWidth: TopbarItemShopWindow.radius + 10, maxWidth: TopbarItemShopWindow.radius * 3)
            }
            .lineLimit(nil)
            .contextMenu {
                ForEach(Rarity.allCases, id: \.self) { i in
                    Button {
                        self.tool.setRarity(i)
                        self.onRarityChange(i)
                    } label: {
                        Label(i.rawValue, systemImage: self.tool.getRarity() == i ? "circle" : "checkmark")
                    }
                    .disabled(!(self.allowChangeToRarity?(self.tool, i) ?? true))
                }
            }
        } else {
            // MARK: - iOS 16.0+
            VStack {
                TopbarItemShopWindow(icon: tool.getIcon(), isActive: isActive)
                    .glowColor(Color(self.tool.getRarity().rawValue, bundle: .module))
              Text(tool.getName().fromLocalized())
              .fontWeight(
                isActive ? .bold : .regular
              )
              .foregroundColor(Color(UIColor.label))
              .font(.caption2)
              .frame(minWidth: TopbarItemShopWindow.radius, idealWidth: TopbarItemShopWindow.radius + 10, maxWidth: TopbarItemShopWindow.radius * 3)
            }
            .contextMenu {
                ForEach(Rarity.allCases, id: \.self) { i in
                    Button {
                        self.tool.setRarity(i)
                        self.onRarityChange(i)
                    } label: {
                        Label(i.rawValue, systemImage: self.tool.getRarity() != i ? "circle" : "checkmark")
                    }
                    .disabled(!(self.allowChangeToRarity?(self.tool, i) ?? true))
                }
            } preview: {
                TopbarItemShopWindow(icon: tool.getIcon(), isActive: isActive)
                    .glowColor(.clear)
                    .padding()
            }
            .lineLimit(nil)
        }
    }
}

extension SpendingTopbarItemView {
    func shouldAllowRarityChange(_ action: @escaping @MainActor (_: SpendingSheetTopbarItem, _: Rarity) -> Bool) -> Self {
        var copy = self
        copy.allowChangeToRarity = action
        return copy
    }
}
