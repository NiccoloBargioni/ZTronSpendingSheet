import Foundation

public protocol Purchaseable: Identifiable, Sendable, Cloneable, Discountable {
    var id: String { get }
    var player: Player? { get }
    
    func getCategories() -> Set<PurchaseableCategory>
    func getAssetsImage() -> String
    func getName() -> String
    func getDescription() -> String
    func getPrice() -> Double
}
