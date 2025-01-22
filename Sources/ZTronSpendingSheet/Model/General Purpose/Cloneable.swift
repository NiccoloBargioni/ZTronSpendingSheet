import Foundation

internal protocol Cloneable {
    func makeDeepCopy() -> Self
}
