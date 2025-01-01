import Foundation

public protocol Cloneable {
    func makeDeepCopy() -> Self
}
