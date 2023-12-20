//
//  PaymentHistoryViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 16/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView


enum MonthType:Int{
    case previous = -1
    case current = 0
    case next = 1
}
class PaymentHistoryViewController: DIBaseController {
    
    // MARK: IBOutlets
    @IBOutlet weak var monthNameLAbel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var totalPayementLabel: UILabel!
    @IBOutlet weak var nextButton:UIButton!
    @IBOutlet weak var previousButton:UIButton!
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = lineShadowView.backgroundColor?.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet weak var bgShadowButton: SSNeumorphicButton!{
        didSet{
            bgShadowButton.btnNeumorphicCornerRadius = 8
            bgShadowButton.btnNeumorphicShadowRadius = 0
            bgShadowButton.btnDepthType = .outerShadow
            bgShadowButton.btnNeumorphicLayerMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
            bgShadowButton.btnNeumorphicShadowOpacity = 0.8
            bgShadowButton.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            bgShadowButton.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            bgShadowButton.btnNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
        }
    }
    
    private var currentDate:Date = Date(){
        didSet{
            let startOfMonth = toLocalTime(date: interval(date:currentDate).start)
            startDate = Calendar.current.date(byAdding: .hour, value: 1, to: startOfMonth)?.timestampInMilliseconds ?? 0
            endDate = interval(date:currentDate).end.timestampInMilliseconds
        }
    }
    private var startDate = Int()
    private var endDate = Int()
    private var firstPaymentDate = Date()
    var paymentHistory:[PaymentHistory]?
    var totalAmount = Double(){
        didSet{
            let stringAmount = String(totalAmount)
            let sepratedAmount = stringAmount.split(separator: ".")
            totalAmountLabel.text = sepratedAmount[1].hasPrefix("0") ? "$\(sepratedAmount[0])" : "$\(totalAmount.rounded(toPlaces: 2))"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeMonth(month: .current, date: currentDate)
        getHistorypfPayment()
    }
    
    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func previousMonthTapped(_ sender: UIButton) {
        changeMonth(month: .previous, date: currentDate)
    }
    @IBAction func nextMonthTapped(_ sender: UIButton) {
        changeMonth(month: .next, date: currentDate)
    }
    
    private func changeMonth(month:MonthType,date:Date){
        let newMonth = Calendar.current.date(byAdding: .month, value: month.rawValue, to: date)
        currentDate = newMonth ?? Date()
        changeUIByMonth(currentDate: currentDate)
    }
    
    private func changeUIByMonth(currentDate:Date){
        if currentDate.toString(inFormat: .paymentHistory) == Date().toString(inFormat: .paymentHistory){
            nextButton.isHidden = true
        }else{
            nextButton.isHidden = false
        }
        if currentDate.toString(inFormat: .paymentHistory) == firstPaymentDate.toString(inFormat: .paymentHistory){
            previousButton.isHidden = true
        }else{
            previousButton.isHidden = false
        }
        let dateString = currentDate.toString(inFormat: .paymentHistory)
        monthNameLAbel.text = dateString
    }
    
    func getHistorypfPayment(){
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable{
            self.showLoader()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            let month = formatter.string(from: currentDate).lowercased()
            
            DIWebLAyerPaymentAPI().getPaymentHistory(startDate:startDate,endDate:endDate,month:month) { data,date in
                self.hideLoader()
                self.paymentHistory = data
                self.paymentHistory?.forEach({ history in
                    self.totalAmount += history.paymentAmout ?? 0
                })
                self.totalPayementLabel.text = "Spent (\(data.count) Payments)"
                self.firstPaymentDate = date.toDate(dateFormat: .fbFormat)
                self.tableView.reloadData()
            } failure: { error in
                self.hideLoader()
                print(error)
            }
        }else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
    
    func interval(date:Date) -> DateInterval {
        guard let interval = Calendar.current.dateInterval(of: .month, for: date) else { return DateInterval()
        }
        return interval
    }
    
    func  toLocalTime(date:Date) -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: date))
        return Date(timeInterval: seconds, since: date)
    }
}

extension PaymentHistoryViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentHistory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentHistoryTableViewCell.reuseIdentifier, for: indexPath) as? PaymentHistoryTableViewCell else{
            return UITableViewCell()
        }
        
        if let history = paymentHistory?[indexPath.row]{
            cell.setData(history: history)
        }
        return cell
    }
    
}

