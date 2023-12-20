//
//  ProfileTextViewCell.swift
//  TemApp
//
//  Created by Harmeet on 18/06/20.
//

import UIKit
import IQKeyboardManagerSwift
protocol ProfileTextViewCellDelegate {
    func submitTapped(text:String)
}
class ProfileTextViewCell: UITableViewCell {
    
    //@IBOutlet weak var accountabilityTextView: UITextView!
    var delegate : ProfileTextViewCellDelegate?
    @IBOutlet var textView: IQTextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var saveBtnHeight: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    /// Custom setter so we can initialise the height of the text view
    //         var textString: String {
    //             get {
    //                 return textView.text
    //             }
    //             set {
    //                 textView.text = newValue
    //
    //                 textViewDidChange(textView)
    //             }
    //         }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Disable scrolling inside the text view so we enlarge to fitted size
        //            textView.isScrollEnabled = false
        //             textView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //             if selected {
        //                 textView.becomeFirstResponder()
        //             } else {
        //                 textView.resignFirstResponder()
        //             }
    }
    
    func configureCell(userProfile:Friends?){
        textView.text = User.sharedInstance.accountabilityMission ?? ""
        textView.borderColor = .gray
        textView.isUserInteractionEnabled = true
        textView.delegate = self
        saveBtn.isHidden = false
        saveBtnHeight.constant = 70
        textView.placeholderTextColor = .gray
        textView.placeholder = "Describe your accountability mission."
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        delegate?.submitTapped(text: textView?.text ?? "")
    }
    
}

//     extension ProfileTextViewCell: UITextViewDelegate {
//        func textViewDidChange(_ textView: UITextView) {
//
//             let size = textView.bounds.size
//            let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
//
//             // Resize the cell only when cell's size is changed
//             if size.height != newSize.height {
//                 UIView.setAnimationsEnabled(false)
//                 tableView1?.beginUpdates()
//                 tableView1?.endUpdates()
//                 UIView.setAnimationsEnabled(true)
//                if let thisIndexPath = tableView1?.indexPath(for: self) {
//                    tableView1?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
//                 }
//             }
//         }
//        func textViewDidEndEditing(_ textView: UITextView) {
//            tableView1?.reloadData()
//        }
//        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//          switch textView.tag {
//          case 0:
//              if  textView.text == "" || textView.text == Constant.Profile.accountabilityMission {
//              textView.text = ""
//              textView.textColor = UIColor.black
//          }
//          default:
//            break
//          }
//          return true
//        }
//     }

     extension UITableViewCell {
         /// Search up the view hierarchy of the table view cell to find the containing table view
         var tableView1: UITableView? {
             get {
                 var table: UIView? = superview
                 while !(table is UITableView) && table != nil {
                     table = table?.superview
                 }

                 return table as? UITableView
             }
         }
     }
extension ProfileTextViewCell:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.textView == textView{
            User.sharedInstance.accountabilityMission = textView.text
        }
    }
}
