//
//  Extension+String.swift
//  VIZU
//
//  Created by Sourav on 9/13/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    /// This variable will holds the length of the string.
    var length: Int {
        return self.count
    }
    
    func toInt() -> Int{
        return Int(self) ?? 0
    }
    
    /// This will check whether a string is empty or not by remove all spaces
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    /// This will check wheher a string is a valid email or not.
    var isValidEmail: Bool {
        let emailRegEx = RegEx.email.rawValue//"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    var checkValidPassword: String {
        if(self.count > 7 && self.count < 17) {
        } else {
            return AppMessages.Password.invalidNewPassword
        }
        let nonUpperCase = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
        let letters = self.components(separatedBy: nonUpperCase)
        let strUpper: String = letters.joined()
        
        if (strUpper.count < 1) {
            return AppMessages.Password.uppercaseCharacter
        }
//        let smallLetterRegEx  = ".*[a-z]+.*"
//        let samlltest = NSPredicate(format:"SELF MATCHES %@", smallLetterRegEx)
//        let smallresult = samlltest.evaluate(with: self)
//        if !smallresult {
//            return AppMessages.Password.lowercaseCharacter
//        }
        let numberRegEx  = ".*[0-9]+.*"
        let numbertest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = numbertest.evaluate(with: self)
        if !numberresult {
            return AppMessages.Password.number
        }
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
        var isSpecial :Bool = false
        if regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, self.count)) != nil {
            print("could not handle special characters")
            isSpecial = true
        }else{
            isSpecial = false
        }
        if !isSpecial {
            return AppMessages.Password.specialCharacter
        }
        
        return AppMessages.CommanMessages.success
        // return (strUpper.count >= 1) && smallresult && numberresult && isSpecial
    }
    
    func isValidPasswordForRange(minLength min: Int = 0, maxLength max: Int) -> Bool {
        if self.count >= min && self.count <= max {
            let regularExpression = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
            let passwordValidation = NSPredicate.init(format: "SELF MATCHES %@", regularExpression)
            return passwordValidation.evaluate(with: self)
        }
        return false
    }
    
    var isValidPassword: Bool {
        
        if self.count > 5 && self.count < 15{
            return true
        }
        return false
    }
    
    func isValidInRange(minLength min: Int = 1, maxLength max: Int = 20) ->  Bool {
        if self.count >= min && self.count <= max {
            return true
        }
        return false
    }
    
    func replace(_ string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    var trim: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func condensed() -> String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var trimmed: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    //It will remove all special 
    var removeSpecialCharacters: String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        
    }
    
    func containsOnlyNumbers() -> Bool {
        let numberRegEx  = "[0-9]*"
        let testCase     = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return testCase.evaluate(with: self)
    }
    
    func disPlayDate() -> String {
        var date:String?
        if self.toInt() != 0 {
            date = self.toInt().toDate.displayDate()!
        }
        return date ?? ""
    }
    
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    //This Fucntion will return Width Of String
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func convertStringToDictionary() -> [String:AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    //This Fucntion will return height Of String
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func utcToLocal(_ withFormat: DateFormat = .preDefined, toFormat: DateFormat = .preDefined) -> String {
        let dateFormatter = DIDateFormator.format(dateFormat: withFormat)
        guard let date = dateFormatter.date(from: self) else {
            return ""
        }
        dateFormatter.dateFormat = toFormat.format
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: date)
    }
    
    func toDate( dateFormat format  : DateFormat = .preDefined) -> Date {
        let dateFormatter = DIDateFormator.format(dateFormat: format)
        if let date = dateFormatter.date(from: self){
            return date
        }
        //print("Invalid arguments ! Returning Current Date . ")
        return Date()
    }
    
    
    /// converts the string value in date
    ///
    /// - Returns: date in utc
    func convertToDate(inFormat format: DateFormat = .preDefined) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.format
        dateFormatter.locale =  Locale(identifier: "en")
        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        return Date()
    }
    
    func convertDateFormatFromUTCToLocal(currentformat:DateFormat = .preDefined ,with format:DateFormat = .fitbitDate) -> String {
        
        let dateFormatter = DateFormatter()
        // dateFormatter.locale =  Locale(identifier: "en")
        dateFormatter.dateFormat = currentformat.format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let CreatedDate = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format.format
        
        if CreatedDate != nil {
            return dateFormatter.string(from: CreatedDate!)
        }else{
            return self
        }
    }
    
    // MARK: Method for Data Parsing.
    var html2String : NSAttributedString? {
        return decodeString(encodedString: self)
    }
    
    func decodeString(encodedString:String) -> NSAttributedString?{
        guard let encodedData = encodedString.data(using: .utf8) else{
            return nil
        }
        do {
            let attributedStr = try NSAttributedString(data: encodedData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)

            let newAttributedString = NSMutableAttributedString(attributedString: attributedStr)

            // Enumerate through all the font ranges
            newAttributedString.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, newAttributedString.length), options: []) { value, range, stop in
                guard let currentFont = value as? UIFont else {
                    return
                }

//                let fontDescriptor = currentFont.fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.family: UIFont.avenirNextMedium])
//
//                // Ask the OS for an actual font that most closely matches the description above
//                if let newFontDescriptor = fontDescriptor.matchingFontDescriptors(withMandatoryKeys: [UIFontDescriptor.AttributeName.family]).first {
//                    let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
                    
                newAttributedString.addAttributes([NSAttributedString.Key.font: UIFont(name: UIFont.avenirNextMedium, size: 15) ?? UIFont.systemFont(ofSize: 15)], range: range)
                }
             return newAttributedString
        }
            
        catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func localToUTC() -> String {
        let dateFormatter = DIDateFormator.format(dateFormat: .preDefined)
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: dt!)
    }
    
    
    // MARK: GetDateFrom TimeStamps.
    func timeStamp2Date(with format:DateFormat = .displayDate) -> Date? {
        let dateFormator = DIDateFormator.format(dateFormat: format)
        if let timeStamp = Double(self) {
            let date = Date(timeIntervalSince1970: timeStamp)
            let dateStr = dateFormator.string(from: date)
            return dateFormator.date(from: dateStr)
        }
        return nil
    }
    
    ///returns the hashtags in the string
    func hashtags() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: RegEx.hashTag.rawValue, options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "").trim
            }
        }
        
        return []
    }
    
    ///returns the attributed string with the changed color of the word containing the special character
    ///- Parameters:
    /// - specialCharacter: # or @
    /// - regex: Regular expression for detection
    func attributedStringFor(specialCharacter: Character, regex: RegEx,fontSize:CGFloat? = 15,fontStyle:String = UIFont.robotoRegular, color: UIColor = UIColor.textBlackColor) -> NSMutableAttributedString? {
        let nsText = self as NSString
        let attributedText = NSMutableAttributedString(string: self)
        let mainTextColorAttribute = [NSAttributedString.Key.foregroundColor: color]
        let mainTextFontAttribute = [NSAttributedString.Key.font: UIFont(name: fontStyle, size: fontSize!) ?? UIFont.systemFont(ofSize: 12.0)]
        attributedText.addAttributes(mainTextColorAttribute, range: NSRange(location: 0, length: nsText.length))
        attributedText.addAttributes(mainTextFontAttribute, range: NSRange(location: 0, length: nsText.length))
        do {
            let regex = try NSRegularExpression(pattern: regex.rawValue, options: [])
            for match in regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsText.length)) {
                //                let colorAttribute = [NSAttributedString.Key.foregroundColor: UIColor.red]
                let fontAttribute = [NSAttributedString.Key.font: UIFont(name: UIFont.robotoBold, size: 15.0) ?? UIFont.systemFont(ofSize: 12.0)]
                //                attributedText.addAttributes(colorAttribute, range: match.range)
                attributedText.addAttributes(fontAttribute, range: match.range)
            }
        } catch (let error) {
            print(error.localizedDescription)
        }
        return attributedText
    }
    
    func containsNoLetter() -> Bool {
        let letters = CharacterSet.letters
        let range = self.rangeOfCharacter(from: letters)
        
        // range will be nil if no letters is found
        if range != nil {
            //println("letters found")
            return false
        }
        else {
            //println("letters not found")
            return true
        }
    }
    
    /// returns whether the string contains the other string, ignoring the case
    func containsIgnoringCase(other: String) -> Bool{
        return self.range(of: other, options: .caseInsensitive) != nil
    }
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    
} // Extension+ String


protocol OptionalString { }
extension String: OptionalString { }

extension Optional where Wrapped: OptionalString {
    var isBlankOption: Bool {
        guard var value = self as? String else { return true }
        value = value.trimmed
        return value.isEmpty
    }
}
extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    var firstCapitalized: String {
        guard let first = first else { return "" }
        return String(first).capitalized + dropFirst()
    }
}
extension Double {
    var stringValue:String {
        return String(self)
    }
    
    // MARK: Function to calculate remaining time for any event.
    func timeRemainingFormatted() -> String {
        let duration = TimeInterval(self)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        let string = formatter.string(from: duration) ?? "" // will return as 1 hour, 12 minutes and 2 seconds
        
        let substrings = string.components(separatedBy: " ")
        let capitalizedStrings = substrings.map { (string) -> String in
            return string.firstUppercased
        }
        let finalString = capitalizedStrings.joined(separator: " ") // will return as 1 Hour, 12 Minutes and 2 Seconds
        return finalString
    }
    
}
extension Int {
    var stringValue:String {
        return String(self)
    }
}
extension String {
    var withoutHtmlTags: String {
      return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    /// converts the string from base64 encoding to the normal string
    func convertFromBase64ToString() -> String? {
        guard let decodedData = Data(base64Encoded: self),
            let decodedString = String(data: decodedData, encoding: .utf8) else {
                return nil
        }
        print("decoded string: \(decodedString)")
        return decodedString
    }
    
    /// get the exact id of  a node by trimming components
    ///for eg. the initial string is gid://shopify/Order/123?key=1234556
    ///return value will be 123
    func getGraphQLNodeId() -> String? {
        if let range = self.range(of: "gid://shopify/Order/") {
            let value = self[range.upperBound...]
            let components = value.components(separatedBy: "?")
            return components.first
        }
        return nil
    }
    
    func getGraphQLCollectionNodeId() -> String? {
        if let range = self.range(of: "gid://shopify/Collection/") {
            let value = self[range.upperBound...]
            let components = value.components(separatedBy: "?")
            return components.first
        }
        return nil
    }
}
extension String {
    func convertToAttributedFromHTML() -> NSAttributedString? {
        var attributedText: NSAttributedString?
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        if let data = data(using: .unicode, allowLossyConversion: true), let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedText = attrStr
        }
        return attributedText
    }
}
extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height

        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}
extension String {
    func convertToAttributedFromHTML2() -> NSAttributedString? {
        var attributedText: NSAttributedString?
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        if let data = data(using: .unicode, allowLossyConversion: true), let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedText = attrStr
        }
        return attributedText
    }
}
extension UIView
{
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}
extension URL {
    var isImage: Bool {
        let imageFormats = ["jpg", "jpeg", "png", "gif"]
        return imageFormats.contains(pathExtension)
    }
}
