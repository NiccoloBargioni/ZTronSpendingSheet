import Ifrit


internal protocol IfriSearchable: Searchable {
    var propertiesCustomWeight: [FuseProp] { get }
}

struct AnySearchable: Searchable {
    private let _propertiesCustomWeight: () -> [FuseProp]

    init<T: IfriSearchable>(_ instance: T) {
        _propertiesCustomWeight = { instance.propertiesCustomWeight }
    }

    var propertiesCustomWeight: [FuseProp] {
        _propertiesCustomWeight()
    }
}
