import SwiftUI

internal struct ShoppingItemCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var onDecoratorTapped: ((CouponType) -> Void)? = nil
    private var onPurchaseTapped: ((any Purchaseable) -> Void)? = nil
    internal var disabled: Bool = false
    
    private var purchaseable: any Purchaseable
    
    internal init(
        purchaseable: any Purchaseable
    ) {
        self.purchaseable = purchaseable
    }
    
    internal var body: some View {
        VStack(spacing: 16) {
            HStack {
                Chip(text: "wwii.side.quests.spending.category.\(purchaseable.getCategories().first!.rawValue.lowercased())".fromLocalized().uppercased())
                Spacer()
            }

            Image(self.purchaseable.getAssetsImage(), bundle: .module)
                .resizable()
                .frame(maxWidth: .infinity)
                .aspectRatio(16.0/9.0, contentMode: .fill)
                .clipped()
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 8) {
                Text(self.purchaseable.getName().fromLocalized().uppercased())
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(self.purchaseable.getDescription().fromLocalized())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack {
                Text("\(String(format: "%.1f", self.purchaseable.getPrice())) ⚡")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(SwiftUI.Color.blue)
                
                Spacer()
                
                Button(action: {
                    onPurchaseTapped?(self.purchaseable)
                }) {
                    Chip(text: "wwii.side.quests.spending.home.shop.add.to.cart.label".fromLocalized())
                        .tint(
                            light:Color(red: 250/255, green: 82/255, blue: 134/255), //Color(red: 250/255, green: 250/255, blue: 251/255),
                            dark: Color(red: 255/255, green: 168/255, blue: 168/255)
                        )
                        .material(
                            light: Color(red: 250/255, green: 82/255, blue: 82/255).opacity(0.15), // Color(red: 250/255, green: 82/255, blue: 134/255),
                            dark: Color(red: 250/255, green: 82/255, blue: 82/255).opacity(0.15)
                        )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .shadow(radius: 8)
        .padding(.horizontal)
    }
    
    internal static func mapCouponTypeToImageName(_ coupon: CouponType) -> String {
        switch coupon {
        case .skeletonKey:
            return "wwii.side.quests.spending.coupon.skeleton.key"
        case .refundCoupon:
            return "wwii.side.quests.spending.coupon.refund.coupon"
        case .blitzMachineCoupon:
            return "wwii.side.quests.spending.coupon.blitz.machine.key"
        case .mysteryBoxKey:
            return "wwii.side.quests.spending.coupon.mystery.box.key"
        }
    }
}    
    

internal extension ShoppingItemCard {
    func onDecoratorTapped(_ action: @escaping (CouponType) -> Void) -> Self {
        var copy = self
        copy.onDecoratorTapped = action
        return copy
    }
    
    func onPurchaseTapped(_ action: @escaping (any Purchaseable) -> Void) -> Self {
        var copy = self
        copy.onPurchaseTapped = action
        return copy
    }
    
    func disabled(_ isDisabled: Bool) -> Self {
        var copy = self
        copy.disabled = isDisabled
        return copy
    }
}
