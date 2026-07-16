import UIKit
import CoreTelephony

@objc public protocol MRCountryPickerDelegate {
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage)
}

struct Country {
    var code: String?
    var name: String?
    var phoneCode: String?
    var flag: UIImage? {
        guard let code = self.code else { return nil }
        let imageName = code.uppercased()
        return UIImage(named: imageName, in: Bundle.module, compatibleWith: nil)
    }

    init(code: String?, name: String?, phoneCode: String?) {
        self.code = code
        self.name = name
        self.phoneCode = phoneCode
    }
}

open class MRCountryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var countries: [Country]!
    open var selectedLocale: Locale?
    open weak var countryPickerDelegate: MRCountryPickerDelegate?
    open var showPhoneNumbers: Bool = true
    open var isCountryFlag = true
    open var externalCountryData: Data?{
        didSet{
            setup()
        }
    }
    
    init(externalCountryData:Data?) {
        super.init(frame: .zero)
        self.externalCountryData = externalCountryData
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    
    func setup() {
        countries = externalCountryData != nil ? countryNamesByCodeForExternalData() : countryNamesByCode()

        if let code = Locale.current.languageCode {
            self.selectedLocale = Locale(identifier: code)
        }

        super.dataSource = self
        super.delegate = self
    }
    
    // MARK: - Locale Methods

    open func setLocale(_ locale: String) {
        self.selectedLocale = Locale(identifier: locale)
    }

    // MARK: - Country Methods
    
    open func setCountry(_ code: String) {
        for index in 0..<countries.count {
            if countries[index].code == code {
                return self.setCountryByRow(row: index)
            }
        }
    }

    open func setCountryByPhoneCode(_ phoneCode: String) {
        for index in 0..<countries.count {
            if countries[index].phoneCode == phoneCode {
                return self.setCountryByRow(row: index)
            }
        }
    }

    open func setCountryByName(_ name: String) {
        for index in 0..<countries.count {
            if countries[index].name == name {
                return self.setCountryByRow(row: index)
            }
        }
    }
    
    // get country data by country code
    open func getCountryByCode(code: String) -> (code: String, name: String, phoneCode: String)? {
        
        if let country = countryNamesByCode().first(where: { $0.code == code }),let countryCode = country.code, let name = country.name, let phoneCode = country.phoneCode
        {
            return (countryCode, name, phoneCode)
        }
        return nil
    }

    func setCountryByRow(row: Int) {
        guard countries.indices.contains(row) else { return }
        self.selectRow(row, inComponent: 0, animated: true)
        let country = countries[row]
        guard let name = country.name,
              let code = country.code,
              let phone = country.phoneCode,
              let flag = country.flag else { return }
        countryPickerDelegate?.countryPhoneCodePicker(self,
                                                      didSelectCountryWithName: name,
                                                      countryCode: code,
                                                      phoneCode: phone,
                                                      flag: flag)
    }
    
    // Populates the metadata from the included json file resource
    func loadCountryCodesData() -> Data? {
        if let url = Bundle.module.url(forResource: "countryCodes",
                                       withExtension: "json",
                                       subdirectory: "SwiftCountryPicker.bundle/Data") {
            return try? Data(contentsOf: url)
        }
        // Fallback: just Data
        if let url = Bundle.module.url(forResource: "countryCodes",
                                       withExtension: "json",
                                       subdirectory: "Data") {
            return try? Data(contentsOf: url)
        }
        // Fallback: root
        if let url = Bundle.module.url(forResource: "countryCodes",
                                       withExtension: "json") {
            return try? Data(contentsOf: url)
        }
        return nil
    }
    func countryNamesByCode() -> [Country] {
        var countries = [Country]()
        let frameworkBundle = Bundle(for: type(of: self))
        guard let jsonData = loadCountryCodesData() else {
            return countries
        }
        
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {

                    for jsonObject in jsonObjects {
                        
                        guard let countryObj = jsonObject as? NSDictionary else {
                            return countries
                        }
                        
                        guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String else {
                            return countries
                        }

                        let country = Country(code: code, name: name, phoneCode: phoneCode)
                        countries.append(country)
                    }

                }
        } catch {
            return countries
        }
        return countries
    }
    
    func countryNamesByCodeForExternalData() -> [Country] {
        var countries = [Country]()
        guard  let jsonData = self.externalCountryData else {
            return countries
        }
        
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {

                    for jsonObject in jsonObjects {
                        
                        guard let countryObj = jsonObject as? NSDictionary else {
                            return countries
                        }
                        
                        guard let code = countryObj["countryCode"] as? String, let phoneCode = countryObj["phonecode"] as? String, let name = countryObj["name"] as? String else {
                            return countries
                        }

                        let country = Country(code: code, name: name, phoneCode: phoneCode)
                        countries.append(country)
                    }

                }
        } catch {
            return countries
        }
        return countries
    }
    // MARK: - Picker Methods
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var resultView: SwiftCountryView
        
        if view == nil {
            resultView = SwiftCountryView()
        } else {
            resultView = view as! SwiftCountryView
        }
        resultView.isCountryFlagShow = self.isCountryFlag
        
        resultView.setup(countries[row], locale: self.selectedLocale)
        if !showPhoneNumbers {
            resultView.countryCodeLabel.isHidden = true
        }
        return resultView
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard countries.indices.contains(row) else { return }
        let country = countries[row]
        guard let name = country.name,
              let code = country.code,
              let phone = country.phoneCode,
              let flag = country.flag else { return }
        countryPickerDelegate?.countryPhoneCodePicker(self,
                                                      didSelectCountryWithName: name,
                                                      countryCode: code,
                                                      phoneCode: phone,
                                                      flag: flag)
    }
}
