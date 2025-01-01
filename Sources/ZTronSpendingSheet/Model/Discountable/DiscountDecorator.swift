import Foundation

public protocol DiscountDecorator: Purchaseable {
    var discountDecorator: any Discountable { get }
}
