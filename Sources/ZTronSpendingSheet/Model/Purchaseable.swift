import Foundation

public protocol Purchaseable: Identifiable, Sendable, Cloneable, Discountable {
    var id: String { get }
    
    func getCategories() -> Set<PurchaseableCategory>
    func getAssetsImage() -> String
    func getName() -> String
    func getDescription() -> String
    func getPrice() -> Double
    func getAvailability() -> Int
    func decrementAvailability(amount: Int) -> Void
    func increaseAvailability(amount: Int) -> Void
    func getAmount() -> Int
    func increaseAmount() -> Void
    func decreaseAmount() -> Void
}

