//
//  ManageCardsViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 23/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ManageCardsViewController: DIBaseController {
    
    // MARK: IBOutlets
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = lineShadowView.backgroundColor?.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet weak var tableView:UITableView!
    
    // MARK: Properties
    var cardDetails:[CardsDetails]?
    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getCards()
    }
    
    
    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Methods
    private func getCards(){
        let isNetworkConnected = self.isConnectedToNetwork(shouldShowMessage: true)
        if isNetworkConnected{
            self.showLoader()
            DIWebLAyerPaymentAPI().getAddedCards { response in
                self.hideLoader()
                self.cardDetails = response
                self.tableView.reloadData()
            } failure: { error in
                print("error \(error.message)")
            }
        }
    }
    
    private func removeCard(cardId:String, at index:Int){
        let isNetworkConnected = self.isConnectedToNetwork(shouldShowMessage: true)
        if isNetworkConnected{
            self.showLoader()
            DIWebLAyerPaymentAPI().removeCard(cardId: cardId) { message in
                self.hideLoader()
                self.cardDetails?.remove(at: index)
                self.showAlert(message: message)
                self.tableView.reloadData()
            }
        }
    }
}

    // MARK: extensions
extension ManageCardsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  cardDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:ManageCardsTableViewCell = tableView.dequeueReusableCell(withIdentifier: ManageCardsTableViewCell.reuseIdentifier) as? ManageCardsTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.setData(card: cardDetails?[indexPath.row].card, index: indexPath.row, cardsCount: cardDetails?.count ?? 0)
        return cell
    }
}

extension ManageCardsViewController:ManageCardsTableViewCellDelegate{
    
    func removeCard(index: Int) {
        if self.cardDetails?.count ?? 0 > 1{
            self.removeCard(cardId: self.cardDetails?[index].id ?? "", at: index)
        }
    }
}
