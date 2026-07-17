import Foundation
import UIKit

private func mr_resourcesBundle(for type: AnyClass) -> Bundle {
    #if SWIFT_PACKAGE
    // When built as a Swift Package, resources live in Bundle.module
    return Bundle.module
    #else
    // When integrated via CocoaPods or direct source, use the class's bundle
    return Bundle(for: type)
    #endif
}

class NibLoadingView: UIView {
    
    @IBOutlet weak var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    fileprivate func nibSetup() {
        backgroundColor = UIColor.clear
        
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nibName = String(describing: type(of: self))
        let bundle = mr_resourcesBundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            assertionFailure("Failed to load nib named \(nibName) from bundle: \(bundle)")
            return UIView()
        }
        return nibView
    }
    
}



class SwiftCountryView: NibLoadingView {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    var isCountryFlagShow = true
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(_ country: Country, locale: Locale?) {
        if let flag = country.flag{
            flagImageView.layer.borderWidth = 0.5
            flagImageView.layer.borderColor = UIColor.darkGray.cgColor
            flagImageView.layer.cornerRadius = 1
            flagImageView.layer.masksToBounds = true
            flagImageView.image = flag
            flagImageView.isHidden = !isCountryFlagShow
        }
        if let code = country.code,
            let locale = locale {
            countryNameLabel.text = code == "PS" ? country.name : locale.localizedString(forRegionCode: code)
            countryCodeLabel.text = country.phoneCode?.converteDigitsToLocale(locale)
        }else{
            countryNameLabel.text = country.name
            countryCodeLabel.text = country.phoneCode
        }
    }
    
}


extension String {
    private static let formatter = NumberFormatter()

    func clippingCharacters(in characterSet: CharacterSet) -> String {
        components(separatedBy: characterSet).joined()
    }

    func converteDigitsToLocale(_ locale: Locale) -> String {
        let digits = Set(clippingCharacters(in: CharacterSet.decimalDigits.inverted))
        guard !digits.isEmpty else { return self }

        Self.formatter.locale = locale
        let maps: [(original: String, converted: String)] = digits.map {
            let original = String($0)
            guard let digit = Self.formatter.number(from: String($0)) else {
                assertionFailure("Can not convert to number from: \(original)")
                return (original, original)
            }
            guard let localized = Self.formatter.string(from: digit) else {
                assertionFailure("Can not convert to string from: \(digit)")
                return (original, original)
            }
            return (original, localized)
        }

        var converted = self
        for map in maps { converted = converted.replacingOccurrences(of: map.original, with: map.converted) }
        return converted
    }
}

