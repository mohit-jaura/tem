//
//  PopVariantsVCViewController.swift
//  TemApp
//
//  Created by PrabSharan on 25/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class PopVariantsVC: DIBaseController {
    var prodCellDesign : [ProdCellDesign] =  [.Price,.Desc]
    var variantsArr = [AllVariants]()
    var variants:[Variants]?
    @IBOutlet weak var heightForContainerView: NSLayoutConstraint!
    var compleiton:((Int) -> ())?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
    }
    
    func initialise() {
        containerView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(ProductFeaturesParentCell.self)
        tableView.registerCell(ProductPriceCell.self)
        tableView.registerCell(DescCell.self)
        manageUI()
    }
    
    func getVariantID(){
        var selVarComb = [String]()
        for i in 0..<variantsArr.count {
            selVarComb.append(variantsArr[i].variants.filter({$0.isSelected}).first?.name ?? "")
        }
        for i in 0..<selVarComb.count {
            variants =    variants?.filter({$0.option1 == selVarComb[i] || $0.option2 == selVarComb[i] || $0.option3 == selVarComb[i]}) ?? []
        }
        print(variants?.first?.id)
        compleiton?(variants?.first?.id ?? 0)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func manageUI() {
        
        if let variants = variants,variants.first?.option1 != "Default Title" {
            let option1 = Array(Set(variants.map({return $0.option1 ?? ""})))
            let option2 = Array(Set(variants.map({return $0.option2 ?? ""})))
            let option3 = Array(Set(variants.filter({$0.option3 != nil }).map({   return $0.option3 ?? ""})))
            
            var variant1:[CustomVarients] = []
            var variant2:[CustomVarients] = []
            var variant3:[CustomVarients] = []
            
            for i in 0..<option1.count {
                let sizeModal = CustomVarients(option1[i], i == 0 )
                variant1.append(sizeModal)
            }
            for i in 0..<option2.count {
                let sizeModal = CustomVarients(option2[i], i == 0 )
                variant2.append(sizeModal)
            }
            for i in 0..<option3.count {
                let sizeModal = CustomVarients(option3[i], i == 0 )
                variant3.append(sizeModal)
            }
                        
            if variant1.count > 0 {
                prodCellDesign.insert(.Feature1, at: 1)
                variantsArr.append(AllVariants( variant1))
            }
            if variant2.count > 0 {
                prodCellDesign.insert(.Feature1, at: 1)
                variantsArr.append(AllVariants( variant2))
            }
            if variant3.count > 0 {
                prodCellDesign.insert(.Feature1, at: 1)
                variantsArr.append(AllVariants(variant3))
            }
            heightForContainerView.constant = CGFloat(variantsArr.count * 120)
            tableView.reloadData()
        }
    }

    @IBAction func chooseAction(_ sender: Any) {
        self.getVariantID()
    }

}
// MARK: UICollection Method
extension PopVariantsVC:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return variantsArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sizeCell = tableView.dequeueReusableCell(withIdentifier: ProductFeaturesParentCell.identifier, for: indexPath) as? ProductFeaturesParentCell else {return UITableViewCell()}
        sizeCell.tag = indexPath.section
        sizeCell.isColorInitialise = false
        sizeCell.variant = variantsArr[indexPath.section].variants
        
        return sizeCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 18))
        //view.backgroundColor = .blue
        let label = UILabel(frame: CGRect(x: 12, y: 0, width: tableView.frame.width, height: 18))
        label.text = "Variant \(section):"
        label.font = UIFont(name: UIFont.avenirNextRegular, size: 13)
        label.textAlignment = .left
        view.addSubview(label)
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return   18 
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

}
