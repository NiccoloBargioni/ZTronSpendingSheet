import SwiftUI
import SwiftUIMasonry
import AlertToast
import ScalingHeaderScrollView
import AxisTabView
import SwiftUISideMenu

public struct SpendingHome: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) private var vSizeClass
    private let quest: SpendingQuest
    
    @State private var numberOfPlayers: Int = 2
    @State private var currentCategory: PurchaseableCategory = .mandatory
    @State private var selection: Int = 0
    @State private var currentPlayerForCart: Player = .player1
    
    @State private var searchQuery: String = ""
    
    @State private var showSideMenu = false
    
    @StateObject private var spendingModel = SpendingModel(validationStrategy: TwoPlayersValidatorStrategy())
    
    private var currentPlayerName: String {
        return "wwii.side.quests.spending.common.\(self.currentPlayerForCart.rawValue.lowercased())".fromLocalized()
    }
    
    public init(quest: SpendingQuest) {
        let appearance = UINavigationBarAppearance()
            appearance.shadowColor = .clear
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        self.quest = quest
    }
    
    @StateObject private var topbarModel: SpendingSheetTopbarModel = .init(
        items: [
            .init(
                icon: "wwii.side.quests.spending.coupon.skeleton.key",
                name: "wwii.side.quests.spending.coupon.skeleton.key".fromLocalized(),
                type: .skeletonKey
            ),
            .init(
                icon: "wwii.side.quests.spending.coupon.mystery.box.key",
                name: "wwii.side.quests.spending.coupon.mystery.box.key".fromLocalized(),
                type: .mysteryBoxKey
            ),
            .init(
                icon: "wwii.side.quests.spending.coupon.refund.coupon",
                name: "wwii.side.quests.spending.coupon.refund.coupon".fromLocalized(),
                type: .refundCoupon
            ),
            .init(
                icon: "wwii.side.quests.spending.coupon.blitz.machine.key",
                name: "wwii.side.quests.spending.coupon.blitz.machine.key".fromLocalized(),
                type: .blitzMachineCoupon
            ),
        ],
        title: "wwii.side.quests.spending.coupons.topbar.title".fromLocalized()
    )
    
    public var body: some View {
        AxisTabView(selection: $selection, constant: ATConstant(axisMode: .bottom)) { state in
            ATBasicStyle(state, color: Color("Brand.500", bundle: .module))
        } content: {
            ShopView(
                model: self.spendingModel,
                category: self.$currentCategory,
                player: self.$currentPlayerForCart
            )
            .searchable(
                text: self.$searchQuery,
                prompt: "\("wwii.side.quests.spending.home.shop.search.prompt".fromLocalized()) \("wwii.side.quests.spending.category.\(self.currentCategory.rawValue.lowercased())".fromLocalized())"
            )
            .tabItem(tag: 0, normal: {
                Image(systemName: "tag")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(UIColor.label))

            }, select: {
                Image(systemName: "tag")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("BrandHighlight", bundle: .module))
            })
            
            //MARK: - CART
            VStack(alignment: .leading) {
                Picker("Which player do you want to visit the cart for", selection: self.$currentPlayerForCart) {
                    
                    ForEach(
                        Player.allCases.compactMap({ player in
                            return self.spendingModel.mapPlayerToNumber(player) > self.numberOfPlayers ? nil : player
                        }),
                        id: \.hashValue
                    ) { player in
                        Text("wwii.side.quests.spending.common.\(player.rawValue.lowercased())".fromLocalized()).tag(player)
                    }
                }
                .pickerStyle(.segmented)
                
                if self.vSizeClass == .regular {
                    self.Topbar()
                }
                
                if let purchasesForCurrentPlayer = self.spendingModel.getPurchasesForPlayer(self.currentPlayerForCart) {
                    if purchasesForCurrentPlayer.count > 0 {
                        
                        List {
                            if self.vSizeClass == .compact {
                                Section {
                                    self.Topbar()
                                }
                            }
                            
                            if self.vSizeClass == .regular {
                                Section {
                                    if let total = self.spendingModel.getTotalSpent(for: self.currentPlayerForCart) {
                                        HStack(alignment: .center) {
                                            Text("wwii.side.quests.spending.home.cart.total.label".fromLocalized())
                                                .font(.title2.weight(.medium))
                                            
                                            Spacer()
                                            
                                            Text("\(total, specifier: "%.2f") ⚡")
                                                .font(.title2.weight(.medium))
                                        }
                                    }
                                }
                            }
                            
                            if let activeCategoriesForCurrentPlayers = self.spendingModel.getCategoriesForPurchases(for: self.currentPlayerForCart) {
                                ForEach(activeCategoriesForCurrentPlayers, id: \.hashValue) { category in
                                    Section("wwii.side.quests.spending.category.\(category.rawValue.lowercased())".fromLocalized()) {
                                        if let purchasesForThisCategory = self.spendingModel.getAllPurchasesForCategory(for: self.currentPlayerForCart, category: category) {
                                            ForEach(purchasesForThisCategory, id: \.id) { thePurchase in
                                                CartItem(purchaseable: thePurchase)
                                                    .onIncrement {
                                                       self.spendingModel.increaseAmountOfPurchaseById(thePurchase.id, for: self.currentPlayerForCart)
                                                       self.spendingModel.objectWillChange.send()
                                                   }
                                                    .onDecrement {
                                                       self.spendingModel.decreaseAmountOfPurchaseById(thePurchase.id, for: self.currentPlayerForCart)
                                                       self.spendingModel.objectWillChange.send()
                                                    }.shouldIncludeCoupon { coupon in
                                                        return self.spendingModel.isConsumableActiveForPlayer(coupon, player: self.currentPlayerForCart)
                                                    }.onDecoratorTapped { tappedCouponType in
                                                        if self.spendingModel.isConsumableActiveForPlayer(tappedCouponType, player: self.currentPlayerForCart) {
                                                            if thePurchase.coupon?.type == tappedCouponType {
                                                                self.spendingModel.releaseCoupon(tappedCouponType, purchaseID: thePurchase.id, for: self.currentPlayerForCart)
                                                            } else {
                                                                if self.spendingModel.getRemainingActivations(consumable: tappedCouponType, player: self.currentPlayerForCart) > 0 {
                                                                    self.spendingModel.useCoupon(tappedCouponType, purchaseID: thePurchase.id, for: self.currentPlayerForCart)
                                                                }
                                                            }
                                                        }
                                                        
                                                        self.spendingModel.objectWillChange.send()
                                                    }
                                                    .decoratorActivationsCount { coupon in
                                                        return self.spendingModel.getRemainingActivations(consumable: coupon, player: self.currentPlayerForCart)
                                                    }
                                                    .listRowInsets(EdgeInsets())

                                            }
                                            .onDelete(perform: { index in
                                                if let theIndex = index.first {
                                                    self.spendingModel.removePurchaseById(purchasesForCurrentPlayer[theIndex].id, for: self.currentPlayerForCart)
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                            
                        }
                    } else {
                        Text("\(String(describing: self.currentPlayerForCart).lowercased().capitalized) \("wwii.side.quests.spending.home.cart.empty.cart.label".fromLocalized())")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                } else {
                    Text("\(String(describing: self.currentPlayerForCart).lowercased().capitalized) \("wwii.side.quests.spending.home.cart.empty.cart.label".fromLocalized())")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                
                Spacer()
            }
            .tabItem(tag: 1, normal: {
                Image(systemName: "cart")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
            }, select: {
                Image(systemName: "cart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("BrandHighlight", bundle: .module))
            })
            .onChange(of: self.currentPlayerForCart) { nextPlayer in
                
                if let couponsForNextPlayer = self.spendingModel.getActiveConsumablesByPlayer(nextPlayer) {
                    var rarityForConsumable: [String: Rarity] = [:]
                    
                    couponsForNextPlayer.forEach { coupon in
                        if let couponID = coupon.id as? String {
                            rarityForConsumable[couponID] = coupon.rarity
                        }
                    }
                    
                    let activeCoupons = rarityForConsumable.keys.map { return $0 }
                    
                    self.topbarModel.replaceSelectedItemsByName(with: activeCoupons) { item in
                        if let rarityOfItem = rarityForConsumable[item.getName()] {
                            item.setRarity(rarityOfItem)
                        }
                    }
                } else {
                    self.topbarModel.replaceSelectedItemsByName(with: []) { _ in }
                }
            }
        }
        .navigationBarTitle("\(self.numberOfPlayers) Players Spending sheet")
        .navigationBarTitleDisplayMode(.inline)
        .saturation(self.showSideMenu ? 0 : 1)
        .sideMenu(isShowing: self.$showSideMenu) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Image("wwii.side.quests.spending.player.avatar", bundle: .module)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    Spacer()
                }
                .padding(.vertical)
                
                Menu {
                    ForEach(
                        Player.allCases.compactMap({ player in
                            return self.spendingModel.mapPlayerToNumber(player) > self.numberOfPlayers ? nil : player
                        }),
                        id: \.hashValue
                    ) { player in
                        Button {
                            withAnimation {
                                self.currentPlayerForCart = player
                            }
                        } label: {
                            HStack {
                                Text("wwii.side.quests.spending.common.\(player.rawValue.lowercased())".fromLocalized())
                                    .font(.body.weight(.bold))
                                
                                Spacer()
                                
                                if player == self.currentPlayerForCart {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text("wwii.side.quests.spending.common.\(self.currentPlayerForCart.rawValue.lowercased())".fromLocalized())
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 7)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.horizontal, 25)
                }
                .tint(.secondary)
                .background {
                    Capsule()
                        .strokeBorder(.secondary, lineWidth: 1.5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation {
                        self.showSideMenu.toggle()
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(UIColor.label))
                }
            }
            
            let validate = self.spendingModel.validate()
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: validate ? "checkmark" : "xmark")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle( validate ? .green : .red)
            }

            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(Array(2...4), id: \.self) { i in
                        Button {
                            self.numberOfPlayers = i
                            self.spendingModel.changeNumberOfPlayer(to: i)
                            self.spendingModel.setValidationStrategy(TwoPlayersValidatorStrategy.makeStrategyFor(players: i))
                            self.spendingModel.objectWillChange.send()
                        } label: {
                            HStack(alignment: .center) {
                                Text("\(i)")
                                
                                Spacer()
                                
                                if self.numberOfPlayers == i {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                        .tint(
                            self.colorScheme == .light ?
                            Color(
                                cgColor: .init(
                                    red: 21.0/255.0,
                                    green: 21.0/255.0,
                                    blue: 21.0/255.0,
                                    alpha: 1.0
                                )
                            ) :
                            Color(
                                cgColor: .init(
                                    red: 234.0/255.0,
                                    green: 234.0/255.0,
                                    blue: 234.0/255.0,
                                    alpha: 1.0
                                )
                            )
                        )
                }
            }
        }
        .task {
            self.spendingModel.changeQuest(self.quest)
        }
        .clipped()

    }
    
    @ViewBuilder private func Topbar() -> some View {
        // MARK: - THE TOPBAR
        TopbarView(topbar: self.topbarModel)
            .onItemSelected { item, itemRarity in
                Task(priority: .userInitiated) { @MainActor in
                    self.spendingModel.addConsumable(item.couponType, player: self.currentPlayerForCart)
                    self.spendingModel.changeConsumableRarity(consumable: item.couponType, to: item.getRarity(), for: self.currentPlayerForCart)
                    self.spendingModel.objectWillChange.send()
                }
            }
            .onItemRemoved { item in
                Task(priority: .userInitiated) { @MainActor in
                    self.spendingModel.addConsumable(item.couponType, player: self.currentPlayerForCart)
                    self.spendingModel.objectWillChange.send()
                }
            }
            .onRarityChange { couponType, newRarity in
                Task(priority: .userInitiated) { @MainActor in
                    self.spendingModel.changeConsumableRarity(consumable: couponType, to: newRarity, for: self.currentPlayerForCart)
                    assert(self.spendingModel.getActiveConsumablesByPlayer(self.currentPlayerForCart)?.first(where: { coupon in
                        coupon.type == couponType
                    })?.rarity == newRarity)
                    self.spendingModel.objectWillChange.send()
                }
            }
            .shouldChangeToRarity { coupon, newRarity in
                return self.spendingModel.canReplaceConsumableRarity(consumable: coupon.couponType, switchingToRarity: newRarity, for: self.currentPlayerForCart)
            }
    }
}
