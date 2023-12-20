import UIKit
import Foundation
import IQKeyboardManagerSwift


open class Tagging: UIView {
    
    static var sharedInstance = Tagging()
    
    // MARK: - Properties
    
    open var symbol: String = "@"
//    open var searchedFor: String?
    open var tagableList: [String]?
    open var defaultAttributes: [String: Any] = {
        return [
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1),
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.init(name: UIFont.robotoRegular, size: 15.0) ?? UIFont.systemFont(ofSize: 12),
        ]
    }()
    open var symbolAttributes: [String: Any] = {
        return [
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor):  #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1),
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.init(name: UIFont.robotoRegular, size: 15.0) ?? UIFont.systemFont(ofSize: 12),
        ]
    }()
    open var taggedAttributes: [String: Any] = {return [
        convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1),
        convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.init(name: UIFont.robotoRegular, size: 15.0) ?? UIFont.systemFont(ofSize: 12),
        ]
    }()
    
    public var taggedList: [TaggingModel] = []
    public weak var dataSource: TaggingDataSource?
    
    private var currentTaggingText: String? {
        didSet {
            guard let currentTaggingText = currentTaggingText, let tagableList = tagableList else {return}
            let matchedTagableList = tagableList.filter {
                $0.contains(currentTaggingText.lowercased()) || $0.contains(currentTaggingText.uppercased())
            }
            dataSource?.tagging(searchUser: currentTaggingText)
            dataSource?.tagging(self, didChangedTagableList: matchedTagableList)
        }
    }
    private var currentTaggingRange: NSRange?
    private var tagRegex: NSRegularExpression! {return try! NSRegularExpression(pattern: "\(symbol)([^\\s\\K]+)")}
    
    // MARK: - Con(De)structor
    
    public init() {
        super.init(frame: .zero)
        
        //        commonSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //        commonSetup()
    }
    
    // MARK: - Public methods
    public func resetValues(){
    taggedList.removeAll()
    }
    
    public func updateTaggedList(allText: String, tagText: String, id:String) {
        guard let range = currentTaggingRange else {return}
        
        let origin = (allText as NSString).substring(with: range)
        let tag = tagFormat(tagText)
        let replace = tag.appending(" ")
        let changed = (allText as NSString).replacingCharacters(in: range, with: replace)
        let tagRange = NSMakeRange(range.location, tag.utf16.count)
        
        taggedList.append(TaggingModel(text: tagText, range: tagRange,id:id))
        for i in 0..<taggedList.count-1 {
            var location = taggedList[i].range.location
            let length = taggedList[i].range.length
            if location > tagRange.location {
                location += replace.count - origin.count
                taggedList[i].range = NSMakeRange(location, length)
            }
        }
        
        //        textView.text = changed
        let valueToSend = updateAttributeText(txt:changed,selectedLocation: range.location+replace.count)
        dataSource?.tagging(valueToSend)
        dataSource?.tagging(self, didChangedTaggedList: taggedList)
    }
    
    private func tagFormat(_ text: String) -> String {
        return symbol.appending(text)
    }
    
}


// MARK: - Tagging Algorithm

extension Tagging {
    
    private func matchedData(taggingCharacters: [Character], selectedLocation: Int, taggingText: String) -> (NSRange?, String?) {
        var matchedRange: NSRange?
        var matchedString: String?
        let tag = String(taggingCharacters.reversed())
        let textRange = NSMakeRange(selectedLocation-tag.count, tag.count)
        
        guard tag == symbol else {
            let matched = tagRegex.matches(in: taggingText, options: .reportCompletion, range: textRange)
            if matched.count > 0, let range = matched.last?.range {
                matchedRange = range
                matchedString = (taggingText as NSString).substring(with: range).replacingOccurrences(of: symbol, with: "")
            }
            return (matchedRange, matchedString)
        }
        
        matchedRange = textRange
        matchedString = symbol
        return (matchedRange, matchedString)
    }
    
    func tagging(textView: UITextView) {
        let selectedLocation = textView.selectedRange.location
        let taggingText = (textView.text as NSString).substring(with: NSMakeRange(0, selectedLocation))
        let space: Character = " "
        let lineBrak: Character = "\n"
        var tagable: Bool = false
        var characters: [Character] = []
        
        for char in Array(taggingText).reversed() {
            if char == symbol.first {
                characters.append(char)
                tagable = true
                break
            } else if char == space || char == lineBrak {
                tagable = false
                break
            }
            characters.append(char)
        }
        
        guard tagable else {
            currentTaggingRange = nil
            currentTaggingText = nil
            return
        }
        
        let data = matchedData(taggingCharacters: characters, selectedLocation: selectedLocation, taggingText: taggingText)
        currentTaggingRange = data.0
//        searchedFor = data.1
        currentTaggingText = data.1

    }
    
    
    func updateAttributeText(txt:String,selectedLocation: Int) -> (NSMutableAttributedString,NSRange){
        let attributedString = NSMutableAttributedString(string: txt)
        attributedString.addAttributes(convertToNSAttributedStringKeyDictionary(defaultAttributes), range: NSMakeRange(0, txt.utf16.count))
        
        taggedList.forEach { (model) in
            let symbolAttributesRange = NSMakeRange(model.range.location, symbol.count)
            let taggedAttributesRange = NSMakeRange(model.range.location+1, model.range.length-1)
            
            attributedString.addAttributes(convertToNSAttributedStringKeyDictionary(defaultAttributes), range: symbolAttributesRange)
            attributedString.addAttributes(convertToNSAttributedStringKeyDictionary(defaultAttributes), range: taggedAttributesRange)
        }
        return (attributedString,NSMakeRange(selectedLocation, 0))
    }
    
    func updateTaggedList(range: NSRange, textCount: Int) {
        taggedList = taggedList.filter({ (model) -> Bool in
            if model.range.location < range.location && range.location < model.range.location+model.range.length {
                return false
            }
            if range.length > 0 {
                if range.location <= model.range.location && model.range.location < range.location+range.length {
                    return false
                }
            }
            return true
        })
        
        for i in 0..<taggedList.count {
            var location = taggedList[i].range.location
            let length = taggedList[i].range.length
            if location >= range.location {
                if range.length > 0 {
                    if textCount > 1 {
                        location += textCount - range.length
                    } else {
                        location -= range.length
                    }
                } else {
                    location += textCount
                }
                taggedList[i].range = NSMakeRange(location, length)
            }
        }
        
        currentTaggingText = nil
        dataSource?.tagging(self, didChangedTaggedList: taggedList)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
