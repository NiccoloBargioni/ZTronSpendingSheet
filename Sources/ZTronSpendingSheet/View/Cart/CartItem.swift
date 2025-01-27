import SwiftUI

internal struct CartItem: View {
    private var thePurchase: any Purchaseable
    internal var onIncrement: (() -> Void)? = nil
    internal var onDecrement: (() -> Void)? = nil
    internal var onDecoratorTapped: ((CouponType) -> Void)? = nil
    internal var decoratorActivationsCount: ((CouponType) -> Int?)? = nil
    internal var shouldIncludeCoupon: ((CouponType) -> Bool)? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    internal init(purchaseable: any Purchaseable) {
        self.thePurchase = purchaseable
    }
    
    internal var body: some View {
        HStack(spacing: 16) {
            Text("").frame(maxWidth: 0)

            Image(thePurchase.getAssetsImage(), bundle: .module)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .clipped()

            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(thePurchase.getName().fromLocalized())
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer()

                    Text("\(thePurchase.getPrice() * CGFloat(thePurchase.getAmount()), specifier: "%.1f") ⚡")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                Text("WWII.side.quests.spending.gate.artillery.bunker.electric.cherry.side.caption")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack {
                    Spacer()

                    HStack(spacing: 0) {
                        Button(action: {
                            if thePurchase.getAmount() > 1 {
                                self.onDecrement?()
                            }
                        }) {
                            Text("−")
                                .frame(width: 32, height: 32)
                                .foregroundColor(self.thePurchase.getAmount() > 1 ? .primary : .gray)
                        }

                        Text("\(self.thePurchase.getAmount())")
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)

                        Button(action: {
                            self.onIncrement?()
                        }) {
                            Text("+")
                                .frame(width: 32, height: 32)
                                .foregroundColor(.primary)
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                }
                .padding(.top, 4)
            }
            
            /*
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(self.thePurchase.getCompatibleCoupons(), id: \.self) { decorator in
                        if self.shouldIncludeCoupon?(decorator) ?? true {
                            DecoratorView(
                                logo: ShoppingItemCard.mapCouponTypeToImageName(decorator),
                                isActive: self.thePurchase.coupon?.type == decorator) {
                                    self.onDecoratorTapped?(decorator)
                                }
                        }
                    }
                }
            }
            .padding(.vertical, 5)
             */
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(
            self.colorScheme == .light ?
                Color(red: 248/255, green: 249/255, blue: 250/255) : Color(uiColor: .systemGray6))
        .cornerRadius(16)
        .shadow(radius: self.colorScheme == .light ? 1 : 4)
        .padding(.horizontal)
        
        /*
        HStack(alignment: .top, spacing: 20) {
            Text("").frame(maxWidth: 0)
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Image(thePurchase.getAssetsImage(), bundle: .module)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 88, height: 88)
                }
                .aspectRatio(1.0, contentMode: .fit)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(UIColor.separator))
                        .shadow(radius: 2)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(self.thePurchase.getCompatibleCoupons(), id: \.self) { decorator in
                            if self.shouldIncludeCoupon?(decorator) ?? true {
                                DecoratorView(
                                    logo: ShoppingItemCard.mapCouponTypeToImageName(decorator),
                                    isActive: self.thePurchase.coupon?.type == decorator) {
                                        self.onDecoratorTapped?(decorator)
                                    }
                            }
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 0) {
                    Text(thePurchase.getName().fromLocalized())
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)

                    Spacer()
                    
                    Text("\(thePurchase.getPrice() * CGFloat(thePurchase.getAmount()), specifier: "%.1f") ⚡")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                }
                
                Text(thePurchase.getDescription().fromLocalized())
                    .font(.headline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                
                Stepper {
                    Text("x \(thePurchase.getAmount())")
                } onIncrement: {
                    self.onIncrement?()
                } onDecrement: {
                    self.onDecrement?()
                }

            }
            
            Spacer()
        }
        */
    }
    
    @ViewBuilder private func DecoratorView(
        logo: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            ZStack {
              Circle()
                .strokeBorder(
                    isActive ? .green :
                    Color(UIColor.label).opacity(0.3),
                    lineWidth: 1.0
                )
                .frame(width: 44, height: 44)

              Circle()
                    .fill(.clear)
                    .frame(width: 44, height: 44)
                
                Image(logo, bundle: .module)
                    .resizable()
                    .frame(width: 44 * 0.65, height: 44 * 0.65)
                    .clipShape(Circle())
            }
        }

    }
}


internal extension CartItem {
    func onIncrement(_ action: @escaping (() -> Void)) -> Self {
        var copy = self
        copy.onIncrement = action
        return copy
    }
    
    func onDecrement(_ action: @escaping (() -> Void)) -> Self {
        var copy = self
        copy.onDecrement = action
        return copy
    }
    
    func onDecoratorTapped(_ action: @escaping ((CouponType) -> Void)) -> Self {
        var copy = self
        copy.onDecoratorTapped = action
        return copy
    }

    func decoratorActivationsCount(_ action: @escaping (CouponType) -> Int?) -> Self {
        var copy = self
        copy.decoratorActivationsCount = action
        return copy
    }
    
    func shouldIncludeCoupon(_ transform: @escaping (CouponType) -> Bool) -> Self {
        var copy = self
        copy.shouldIncludeCoupon = transform
        return copy
    }
}
