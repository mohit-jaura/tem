//
//  TematesTableCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class TematesTableCell: UITableViewCell {

    //MARK: Variables
    var addButtonIndex: OnlyIntCompletion?

    //MARK: IBOutlet
    @IBOutlet weak var userNAmeLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!


    //MARK: IBAtion
    @IBAction func addButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setTitle("ADDED", for: .normal)
        } else{
            sender.setTitle("ADD", for: .normal)
        }
        addButtonIndex?(sender.tag)
    }

    func configureViewforBookmarkedTodo(isButtonSelected: Bool,data: ToDoList){
        if isButtonSelected{
            addButton.setTitle("SELECTED", for: .normal)
        } else{
            addButton.setTitle("SELECT", for: .normal)
        }
        userNAmeLabel.text = data.title?.uppercased()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
