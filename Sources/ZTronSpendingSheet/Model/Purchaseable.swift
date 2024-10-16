import Foundation

internal protocol Purchaseable: Identifiable, Sendable, Cloneable {
    var id: String { get }
    func getName() -> String
    func getPrice() -> Double
}
