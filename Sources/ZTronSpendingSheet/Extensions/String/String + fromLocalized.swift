import Foundation

internal extension String {
    func fromLocalized() -> String {
        return String(
            localized: String.LocalizationValue(self),
            bundle: .module,
            locale: Locale(
                identifier: Locale.preferredLanguages.first ?? "en-US"
            )
        )
    }
}
