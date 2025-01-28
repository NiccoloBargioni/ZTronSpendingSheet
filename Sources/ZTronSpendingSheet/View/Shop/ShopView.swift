import SwiftUI
import ScalingHeaderScrollView
import SwiftUIMasonry
import AlertToast
@preconcurrency import Ifrit

internal struct ShopView: View {
    @Environment(\.verticalSizeClass) private var vSizeClass
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    
    @Binding private var currentCategory: PurchaseableCategory
    @Binding private var currentPlayer: Player
    @Binding private var query: String
    
    @State private var lastPurchase: (any Purchaseable)? = nil
    @State private var isToastPresenting: Bool = false
    
    @ObservedObject private var spendingModel: SpendingModel
    @Namespace private var animationsNS
    
    @State private var searchResults: [any Purchaseable] = .init()
    private let fuse: Fuse = .init()
    
    
    
    private var currentPlayerName: String {
        return "wwii.side.quests.spending.common.\(self.currentPlayer.rawValue.lowercased())".fromLocalized()
    }
    
    private var purchaseablesInThisCategory: [any Purchaseable]? {
        return spendingPurchaseables.filter { purchaseable in
            purchaseable.getCategories().contains(self.currentCategory)
        }
    }
    
    internal init(
        model: SpendingModel,
        category: Binding<PurchaseableCategory>,
        player: Binding<Player>,
        searchQuery: Binding<String> = .constant("")
    ) {
        self._currentPlayer = player
        self._currentCategory = category
        self._spendingModel = ObservedObject(wrappedValue: model)
        self._query = searchQuery
    }
    
    internal var body: some View {
        ScalingHeaderScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - THE SECTION SELECTOR
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 20) {
                            ForEach(PurchaseableCategory.allCases) { category in
                                Button {
                                    withAnimation {
                                        self.currentCategory = category
                                        scrollProxy.scrollTo(category.rawValue, anchor: .center)
                                    }
                                } label: {
                                    if self.currentCategory != category {
                                        Text("wwii.side.quests.spending.category.\(category.rawValue.lowercased())".fromLocalized())
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Color("BrandHighlight", bundle: .module))
                                            .padding(.vertical, 5)
                                            .padding(.horizontal, 20)
                                            .background {
                                                if self.currentCategory == category {
                                                    Capsule()
                                                        .fill(.clear)
                                                        .matchedGeometryEffect(id: "selected background capsule", in: self.animationsNS)
                                                }
                                            }
                                    } else {
                                        Text("wwii.side.quests.spending.category.\(category.rawValue.lowercased())".fromLocalized())
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(Color("Brand.500", bundle: .module))
                                            .padding(.vertical, 5)
                                            .padding(.horizontal, 20)
                                            .background {
                                                if self.currentCategory == category {
                                                    Capsule()
                                                        .fill(Color("BrandHighlight", bundle: .module))
                                                        .matchedGeometryEffect(id: "selected background capsule", in: self.animationsNS)
                                                }
                                            }
                                    }
                                }
                                .id(category.rawValue)
                            }
                        }
                        .accentColor(.primary)
                    }
                    .padding(.vertical)
                    .padding(.horizontal)
                    .background(Color("Brand.500", bundle: .module))
                    .shadow(radius: 2, y: 1)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - THE CARD
                Group {
                    if self.vSizeClass == .regular {
                        VStack(alignment: .leading, spacing: 30) {
                            if self.isSearching {
                                ForEach(self.searchResults, id: \.id) { item in
                                    PurchaseableCard(purchaseable: item)
                                }
                            } else {
                                ForEach(spendingPurchaseables.filter {
                                    return $0.getCategories().contains(self.currentCategory) && $0.getAvailability() > 0
                                }, id: \.id) { item in
                                    PurchaseableCard(purchaseable: item)
                                }
                            }
                        }
                    } else {
                        VMasonry(columns: 2, spacing: 30) {
                            if self.isSearching {
                                ForEach(self.searchResults, id: \.id) { item in
                                    PurchaseableCard(purchaseable: item)
                                }
                            } else {
                                ForEach(spendingPurchaseables.filter {
                                    return $0.getCategories().contains(self.currentCategory) && $0.getAvailability() > 0
                                }, id: \.id) { item in
                                    PurchaseableCard(purchaseable: item)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .hideScrollIndicators()
        .height(min: 63, max: 63)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toast(isPresenting: self.$isToastPresenting, duration: 2.0, tapToDismiss: true) {
            AlertToast(
                displayMode: .alert,
                type: .complete(SwiftUI.Color.green),
                title: "\("wwii.side.quests.spending.home.shop.toast.title".fromLocalized()) \(self.lastPurchase?.getName().fromLocalized() ?? "(nil)")",
                subTitle: "\("wwii.side.quests.spending.home.shop.toast.subheadline".fromLocalized()) **\(self.currentPlayerName)**"
            )
        }
        .clipped()
        .onChange(of: self.query) { searchText in
            if searchText.isEmpty {
                self.searchResults = self.purchaseablesInThisCategory?.filter {
                    return $0.getAvailability() > 0
                } ?? .init()
            } else {
                Task(priority: .userInitiated) {
                    await self.search(text: searchText)
                }
            }
        }
    }
    
    nonisolated private func search(text: String) async {
        guard let purchasesInThisCategory = await self.purchaseablesInThisCategory else { return }
        let searchablePurchases = purchasesInThisCategory.map({ purchase in
            return AnySearchable(purchase)
        })
        
        let searchResults = await self.fuse.search(text, in: searchablePurchases, by: \.propertiesCustomWeight)
        
        let matchingPurchases = searchResults.map {
            return purchasesInThisCategory[$0.index]
        }
        
        await MainActor.run {
            self.searchResults = matchingPurchases
        }
    }
    
    @ViewBuilder private func PurchaseableCard(purchaseable: any Purchaseable) -> some View {
        ShoppingItemCard(purchaseable: purchaseable)
            .onPurchaseTapped { purchase in
                self.lastPurchase = purchase
                self.isToastPresenting.toggle()
                self.spendingModel.appendPurchase(purchase, to: self.currentPlayer)
            }
            .disabled(
                purchaseable.getAvailability() <= 0
            )
    }
}
