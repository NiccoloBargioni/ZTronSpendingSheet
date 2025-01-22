import SwiftUI

@MainActor internal struct TopbarView: View {
    @ObservedObject private var topbar: SpendingSheetTopbarModel
    internal var onRarityChange: (@Sendable (_: CouponType, _: Rarity) -> Void)?
    internal var onItemSelected: (@Sendable (_: SpendingSheetTopbarItem, _: Rarity?) -> Void)?
    internal var onItemUnselected: (@Sendable (_: SpendingSheetTopbarItem) -> Void)?
    internal var canChangeToRarity: (@MainActor (_: SpendingSheetTopbarItem, _: Rarity) -> Bool)?
    
    internal init(
        topbar: SpendingSheetTopbarModel,
        onItemSelected: (@Sendable (_: SpendingSheetTopbarItem, _: Rarity?) -> Void)? = nil,
        onRarityChange: (@Sendable (_: CouponType, _: Rarity) -> Void)? = nil,
        onItemUnselected: (@Sendable (_: SpendingSheetTopbarItem) -> Void)? = nil,
        canChangeToRarity: (@MainActor (_: SpendingSheetTopbarItem, _: Rarity) -> Bool)? = nil
    ) {
        self._topbar = ObservedObject(wrappedValue: topbar)
        self.onItemSelected = onItemSelected
        self.onRarityChange = onRarityChange
        self.onItemUnselected = onItemUnselected
        self.canChangeToRarity = canChangeToRarity
    }
    
    internal var body: some View {
        //MARK: - Topbar
         VStack(alignment: .leading, spacing: 0) {
            
            //MARK: Topbar title
            HStack {
                Text(
                    LocalizedStringKey(
                        String(self.topbar.title)
                    )
                )
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .font(.headline)
                    .foregroundColor(
                        Color(UIColor.label)
                            .opacity(0.7)
                    )
                Spacer()
            }
            
            Divider()
                .padding(0)
            
            //MARK: Topbar item selection view
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { scroll in
                    HStack(alignment: .top, spacing: 25) {
                        ForEach(0..<topbar.count(), id:\.self) { i in
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    let itemModel = self.topbar.get(i)
                                    
                                    if !self.topbar.getSelectedItems().contains(i) {
                                        self.onItemSelected?(itemModel, nil)
                                    } else {
                                        self.onItemUnselected?(itemModel)
                                    }
                                    
                                    topbar.addSelectedItem(item: i)
                                }
                            }) {
                                SpendingTopbarItemView(
                                    tool: topbar.get(i),
                                    isActive: topbar.getSelectedItems().contains(i)
                                ) { newRarity in
                                    Task(priority: .userInitiated) { @MainActor in
                                        if !self.topbar.getSelectedItems().contains(i) {
                                            self.onItemSelected?(self.topbar.get(i), newRarity)
                                            self.topbar.addSelectedItem(item: i)
                                        } else {
                                            self.onRarityChange?(topbar.get(i).couponType, newRarity)
                                        }
                                    }
                                }
                                .shouldAllowRarityChange { consumable, toRarity in
                                    return self.canChangeToRarity?(consumable, toRarity) ?? true
                                }
                            }
                            .id(i)
                            .disabled(self.topbar.getSelectedItems().count > 1 && !self.topbar.getSelectedItems().contains(i))
                        }
                        
                    }
                    .frame(maxHeight: 100)
                    .onChange(of: self.topbar.getSelectedItems()) { newSelectedItemsSet in
                        if let lastSelected = newSelectedItemsSet.randomElement() {
                            withAnimation(.linear(duration: 0.25)) {
                                scroll.scrollTo(lastSelected, anchor: .center)
                            }
                        }
                    }
                }
            }
            .padding()
             
        }
        .frame(maxWidth: .infinity)
        .background {
            Color(UIColor.label)
                .opacity(0.05)
        }
    }
    
}

internal extension TopbarView {
    func onItemSelected(_ action: @escaping @Sendable (_: SpendingSheetTopbarItem, _: Rarity?) -> Void) -> Self {
        var copy = self
        copy.onItemSelected = action
        return copy
    }
    
    func onRarityChange(_ action: @escaping @Sendable (_: CouponType, _: Rarity) -> Void) -> Self {
        var copy = self
        copy.onRarityChange = action
        return copy
    }
    
    func onItemRemoved(_ action: @escaping @Sendable (_: SpendingSheetTopbarItem) -> Void) -> Self {
        var copy = self
        copy.onItemUnselected = action
        return copy
    }
    
    func shouldChangeToRarity(_ action: @escaping @MainActor (_: SpendingSheetTopbarItem, _: Rarity ) -> Bool) -> Self {
        var copy = self
        copy.canChangeToRarity = action
        return copy
    }
}
