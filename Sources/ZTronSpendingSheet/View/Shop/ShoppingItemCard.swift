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
        VStack(alignment: .leading, spacing: 0) {
            
            Image(self.purchaseable.getAssetsImage(), bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .topLeading) {
                    Text("wwii.side.quests.spending.category.\(purchaseable.getCategories().first!.rawValue.lowercased())".fromLocalized().uppercased())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background {
                            Rectangle()
                                .fill(.black.opacity(0.7))
                                .offset(x: -15)
                                .padding(.trailing, -15)
                                .cornerRadius(15, corners: [.bottomRight])
                                .overlay {
                                    RoundedCorner(radius: 15, corners: [.bottomRight])
                                        .stroke(.white, lineWidth: 0.3)
                                }
                        }
                }
            
            Divider()
            
            Group {
                VStack(alignment: .leading, spacing: 8) {
                    Text(self.purchaseable.getName().uppercased())
                        .font(.title2.weight(.black))
                    
                    Text(self.purchaseable.getDescription())
                        .foregroundStyle(.gray)
                        .font(.subheadline.weight(.bold))

                    Divider()
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("\(String(format: "%.1f", self.purchaseable.getPrice())) ⚡")
                            .font(.title2.weight(.bold))
                            .padding(.vertical, 10)
                        
                        Spacer()
                        
                        Button {
                            onPurchaseTapped?(self.purchaseable)
                        } label: {
                            Chip(text: "wwii.side.quests.spending.home.shop.add.to.cart.label".fromLocalized())
                                .fontWeight(.heavy)
                                .softColor(Color.rgba(254, 202, 202))
                                .highlightColor(Color.rgba(153, 25, 25))
                                .leftComponent {
                                    Image(systemName: "plus")
                                        .foregroundStyle(
                                            self.colorScheme == .light ?
                                            Color.rgba(153, 25, 25) :
                                                Color.rgba(254, 202, 202)
                                        )
                                        .font(.system(size: 14))
                                        .erasedToAnyView()
                                }
                        }
                        .disabled(self.disabled)
                    }
                    .padding(.vertical, 5)
                    .padding(.trailing, 15)
                    
                    Divider()
                }
                .padding(.top, 12)
                
                
            }
            .padding(.leading, 15)
            
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color(UIColor.tertiarySystemGroupedBackground), lineWidth: 1)
                .shadow(radius: 1, y: -0.5)
        }
        .saturation(self.disabled ? 0.0 : 1.0)
    }
    
    internal static func mapCouponTypeToImageName(_ coupon: CouponType) -> String {
        switch coupon {
        case .skeletonKey:
            return "skeletonKey"
        case .refundCoupon:
            return "refundCoupon"
        case .blitzMachineCoupon:
            return "blitzMachineCoupon"
        case .mysteryBoxKey:
            return "mysteryBoxKey"
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
