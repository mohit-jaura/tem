//
//  CreateActivityAdOnsVC.swift
//  TemApp
//
//  Created by Gurpreet Kanda on 22/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//
enum Duration :Int{
    case Free = 0
    case AddDuration
}
import UIKit
import SSNeumorphicView
class CreateActivityAdOnsVC: DIBaseController {

    @IBOutlet weak var heightDuration: NSLayoutConstraint!
    @IBOutlet weak var segmentButOut: UISegmentedControl!
    @IBOutlet weak var pickerContainerView: UIStackView!
    @IBOutlet weak var durationTextView: UITextField!
    @IBOutlet weak var radioImgView: UIImageView!
    @IBOutlet weak var radioContainerView: SSNeumorphicView!
    @IBOutlet var allViews: [SSNeumorphicView]!
    @IBOutlet weak var mainCatOut: UIButton!
    @IBOutlet weak var subActivityOut: UIButton!
    @IBOutlet weak var activityTimeOut: UIButton!
    @IBOutlet var timePickerView: UIPickerView!
    var saveAddOns:AddOnCompetion?
    var activityDataModal:ActivityAddOns?
    
     var hour: Int = 0
     var minutes: Int = 0
     var seconds: Int = 0
    var allCategories:[ActivityCategory]?
    var subActivities:[ActivityData]?
    var close:OnlySuccess?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
    }
    func initialise() {
        subActivityOut.isEnabled = false
        allViews.forEach({ setNeumorphicView(view:$0)})
        radioImgView.image = UIImage.radioSel
        getActivitiesFromBackend()
        setToggleShadow(radioContainerView)
        self.pickerContainerView.transform = CGAffineTransform(translationX: 0, y: 300)
    //    self.timePickerView.delegate = self
 //       self.timePickerView.dataSource = self
        self.activityTimeOut.setTitle( "", for: .normal)
        segmentButOut.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    }
    
    @IBAction func doneButtonPickerAction(_ sender: Any) {
        pickerShowHide()
        timeChoose()
    }
    
    @IBAction func categoryAction(_ sender: Any) {
        if allCategories == nil {
            getActivitiesFromBackend({
                self.openCategorySheet()
            })
        }else {
            openCategorySheet()
        }
    }
    
    
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
            
            let isFreeTime = Duration(rawValue: sender.selectedSegmentIndex)  ?? .Free == .Free
            
            self.activityTimeOut.setTitle( isFreeTime ? "" : "Duration", for: .normal)
            
            if isFreeTime {
                self.hour = 0;self.minutes = 0;self.seconds = 0
            }else {
                self.pickerShowHide()
            }
            self.heightDuration.constant = isFreeTime ? 0 : 65
        }, completion: nil)

    }
    
    
    @IBAction func mandatryAction(_ sender: Any) {
        if isMandatry() {
                radioImgView.image = nil
            } else {
                radioImgView.image = UIImage.radioSel
            }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func openCategorySheet() {
        guard let allCategories = allCategories else {return}
        self.showSelectionModal(array: allCategories, type: .activityCategory)
        //Need to open subcategory
    }
    
    func openSubActivitySheet() {
        if let subcategories = allCategories?.filter({$0.selected}).first?.type,subcategories.count != 0 {
            self.subActivities = subcategories
            self.showSelectionModal(array: subcategories, type: .activity)
        }else {
            self.subActivityOut.isEnabled = true
            self.showAlert( message:AppMessages.GroupActivityMessages.activityNotFound )
        }
    }
    
    @IBAction func saveButAction(_ sender: Any) {
        showLoader()
        if checkValidation() {
                self.saveAddOns?(self.activityDataModal)
                self.resetAll()
                self.hideLoader()
            self.alertOpt("Save successfull")
        }else {
            hideLoader()
        }
        
    }
    func resetAllCategory() {
        self.allCategories = allCategories?.map({$0
        var temp = $0
        temp.selected = false
        return temp
        })
    }
    func resetAll() {
        resetAllCategory()
        self.mainCatOut.setTitle("Category", for: .normal)
        self.subActivityOut.setTitle("Activity", for: .normal)
        self.activityTimeOut.setTitle("", for: .normal)
        self.subActivities = nil
        hour = 0;minutes = 0; seconds = 0
        segmentButOut.selectedSegmentIndex  = 0
        radioImgView.image = UIImage.radioSel
        heightDuration.constant = 0
    }
    
    func checkValidation() -> Bool {
        
        guard let selectedCategory = allCategories?.filter({$0.selected}).first else {self.alertOpt(Constant.ErrorMsg.noCategory);return false  }
        
        
        guard let selectedActivity = subActivities?.filter({$0.selected}).first else {self.alertOpt(Constant.ErrorMsg.noActivity);return false  }
        
        let isDurationSel = Duration(rawValue: segmentButOut.selectedSegmentIndex)  ?? .Free == .AddDuration
        
        let isDurationNotAdded = hour == 0 && minutes == 0 && seconds == 0
        
        if (isDurationSel &&  isDurationNotAdded){
            self.alertOpt(Constant.ErrorMsg.noDuration)
            return false
        }
       
        
        self.activityDataModal = ActivityAddOns(
            selectedActivity.activityType,
            selectedCategory.name,
            selectedActivity.id,
            selectedActivity.name,
            calculatedTime(),
            isMandatry() ? 1 : 0,
            selectedActivity.image,
            selectedActivity.metValue,
            selectedActivity.isBinary
        )

        return true
    }
    func calculatedTime() -> Int{
        
        let hoursIntoSec = hour * 3600
        let minIntoSec = minutes * 60
        return hoursIntoSec + minIntoSec + seconds
    }
    func isMandatry() -> Bool {
        if let img = radioImgView.image {
            if (img == UIImage.radioSel) {
                return true
            }}
            return false
    }
    
    @IBAction func activityTimeAction(_ sender: Any) {
        pickerShowHide()
        
    }
    
    func pickerShowHide(){
        TimePicker.presentPicker(self) {[weak self] h, m, s in
            self?.hour = h
            self?.seconds = s
            self?.minutes = m
            self?.timeChoose()
        }
    }
    
    @IBAction func activityAction(_ sender: Any) {
        openSubActivitySheet()
    }
    override func handleSelection(index: Int, type: SheetDataType) {
        switch type{
        case .activity:
            let selectedSubCat = subActivities?[index]
            self.subActivityOut.setTitle(selectedSubCat?.name?.capitalized, for: .normal)
            self.subActivities = self.subActivities?.map({$0
                var temp = $0
                temp.selected  = false
                return temp
            })
            // We need to just log binary, no need to select time here so hiding segment here
            self.segmentButOut.isHidden = selectedSubCat?.isBinary == 1

            self.subActivities?[index].selected = true
        case .activityCategory:
            subActivityOut.isEnabled = true
            let selectedMainCategory = self.allCategories?[index].name
            
            self.mainCatOut.setTitle(selectedMainCategory?.capitalized, for: .normal)
            
            resetAllCategory()

            self.allCategories?[index].selected = true
            DispatchQueue.main.asyncAfter(deadline:  .now() + 0.4) {
                self.openSubActivitySheet()

            }

        default:break
        }
    }
}
extension CreateActivityAdOnsVC :UITextFieldDelegate{
    
   func timeChoose() {
        let str =  "\(hour)h \(minutes)m \(seconds)s"
            print(str)
        self.view.endEditing(true)
        self.activityTimeOut.setTitle(str, for: .normal)

    }
  
    
    func getActivitiesFromBackend(_ completion:OnlySuccess? = nil){
        self.showLoader()
        DIWebLayerActivityAPI().getUserActivity( success: {[weak self] (activities) in
            guard let self = self else {return}
            DispatchQueue.main.async {
            self.hideLoader()
            self.allCategories?.removeAll()
            self.subActivities?.removeAll()
            self.allCategories = activities
            }
            
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
}
extension CreateActivityAdOnsVC: UIPickerViewDelegate, UIPickerViewDataSource {

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:
                return 24
            case 1, 2:
                return 60
            default:
                return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return pickerView.frame.size.width/3
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            switch component {
            case 0:
                return "\(row) hour"
            case 1:
                return "\(row) min"
            case 2:
                return "\(row) sec"
            default:
                return ""
            }
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch component {
            case 0:
                hour = row
            case 1:
                minutes = row
            case 2:
                seconds = row
            default:
                break
            }
        }
    }
