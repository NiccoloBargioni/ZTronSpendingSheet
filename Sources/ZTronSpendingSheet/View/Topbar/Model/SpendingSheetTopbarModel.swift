import Foundation

internal final class SpendingSheetTopbarModel : ObservableObject {
    internal let id: String
    
    internal let title: String
    @Published private var selectedItem: Set<Int> = .init()
    @Published private var items: [SpendingSheetTopbarItem]
    @Published private(set) internal var redacted: Bool = true
    
    private var lastAction: TopbarAction = .selectedItemChanged
    
    internal init(items: [SpendingSheetTopbarItem], title: String, selectedItem: Int? = nil) {
        self.items = items
        self.title = title
        self.selectedItem = Set<Int>()
        self.id = "\(title) topbar"

        if let selectedItem = selectedItem {
            self.selectedItem.insert(selectedItem)
        }
            
    }
    
    internal func count() -> Int {
        return self.items.count
    }
    
    internal func get(_ pos: Int) -> SpendingSheetTopbarItem {
        assert(pos >= 0 && pos < self.items.count)
        return self.items[pos]
    }
    
    internal func addSelectedItem(item: Int) {
        assert(item >= 0 && item < self.items.count)
        
        if selectedItem.contains(item) {
            self.selectedItem.remove(item)
        } else {
            if self.selectedItem.count < 2 {
                self.selectedItem.insert(item)
            }
        }
        
        self.lastAction = .selectedItemChanged
    }
    
    internal func getSelectedItems() -> Set<Int> {
        return self.selectedItem
    }

    func getTitle() -> String {
        return self.title
    }

    internal static func == (lhs: SpendingSheetTopbarModel, rhs: SpendingSheetTopbarModel) -> Bool {
        return lhs.items.count == rhs.items.count && lhs.items.enumerated().reduce(true, { equalsUntilNow, item in
            item.element === rhs.items[item.offset]
        }) && lhs.title == rhs.title && lhs.selectedItem == rhs.selectedItem
    }
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    internal func replaceSelectedItemsByName(with: [String], produce: @escaping (_: inout SpendingSheetTopbarItem) -> Void) {
        self.selectedItem.removeAll()
        
        self.items.enumerated().forEach { i, item in
            var itemCopy = item
            if with.contains(item.getName()) {
                produce(&itemCopy)
                self.items.replaceSubrange(i...i, with: [itemCopy])
                self.selectedItem.insert(i)
            }
        }
    }
}

internal enum TopbarAction {
    case selectedItemChanged
    case itemsReplaced
}
