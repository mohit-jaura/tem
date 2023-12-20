//
//  TagPeopleViewController+UITableView.swift
//  TemApp
//
//  Created by shilpa on 17/12/19.
//

import Foundation

// MARK: UITableViewDataSource
extension TagPeopleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let mediaType = self.currentMediaDisplayed.type {
            switch mediaType {
            case .photo:
                return 1
            case .video:
                return 2
            case .pdf:
                break
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mediaType = self.currentMediaDisplayed.type {
            switch mediaType {
            case .photo:
                tableView.isScrollEnabled = false
                return 1
            case .video:
                if let currentSection = VideoSection(rawValue: section) {
                    switch currentSection {
                    case .emptyTag:
                        //if there is the tagging users list, return that much number of rows
                        if self.media[currentMediaIndex].taggedPeople == nil {
                            return 1
                        }
                        if let taggedPeople = self.media[currentMediaIndex].taggedPeople,
                            taggedPeople.isEmpty {
                            tableView.isScrollEnabled = false
                            return 1
                        }
                    case .taggedPeople:
                        tableView.isScrollEnabled = true
                        return self.media[currentMediaIndex].taggedPeople?.count ?? 0
                    }
                }
            case .pdf:
                break
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let mediaType = self.currentMediaDisplayed.type {
            switch mediaType {
            case .photo:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TagOnPhotoTableCell") {
                    return cell
                }
            case .video:
                if let currentSection = VideoSection(rawValue: indexPath.section) {
                    switch currentSection {
                    case .emptyTag:
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "TagOnVideoTableCell") as? TagOnVideoTableViewCell {
                            cell.roundAddButton.setImageColor(color: UIColor.appThemeColor)
                            return cell
                        }
                    case .taggedPeople:
                        if let cell = tableView.dequeueReusableCell(withIdentifier: TaggedUserTableViewCell.reuseIdentifier, for: indexPath) as? TaggedUserTableViewCell {
                            cell.delegate = self
                            if let taggedPeople = self.media[currentMediaIndex].taggedPeople,
                                indexPath.row < taggedPeople.count {
                                cell.initialize(user: taggedPeople[indexPath.row].taggedUser ?? Friends(), currentSection: currentMediaIndex, row: indexPath.row)
                            }
                            cell.setVisibilityOfCrossButton(shouldHide: false)
                            cell.lineView.isHidden = true
                            return cell
                        }
                    }
                }
            case .pdf:
                break
            }
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension TagPeopleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mediaType = self.currentMediaDisplayed.type,
            mediaType == .video,
            let currentSection = VideoSection(rawValue: indexPath.section),
            currentSection == .emptyTag {
            self.presentUsersListingToTag()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let mediaType = self.currentMediaDisplayed.type {
            switch mediaType {
            case .photo:
                return self.view.frame.size.height * 0.3 //aspect ratio
            case .video:
                if self.media[currentMediaIndex].taggedPeople == nil {
                    return self.view.frame.size.height * 0.3 //aspect ratio
                }
                if let taggedPeople = self.media[currentMediaIndex].taggedPeople,
                    taggedPeople.isEmpty {
                    return self.view.frame.size.height * 0.3 //aspect ratio
                }
            case .pdf:
                break
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let currentSection = VideoSection(rawValue: section),
            currentSection == .taggedPeople {
            if let mediaType = self.currentMediaDisplayed.type,
                mediaType == .video,
                let taggedPeople = self.media[currentMediaIndex].taggedPeople,
                !taggedPeople.isEmpty {
                let tagAnotherHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TagAnotherPersonSectionView.reuseIdentifier) as! TagAnotherPersonSectionView
                tagAnotherHeaderView.delegate = self
                return tagAnotherHeaderView
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let currentSection = VideoSection(rawValue: section),
            currentSection == .taggedPeople {
            if let mediaType = self.currentMediaDisplayed.type,
                mediaType == .video,
                let taggedPeople = self.media[currentMediaIndex].taggedPeople,
                !taggedPeople.isEmpty {
                return 54.0
            }
        }
        return CGFloat.leastNormalMagnitude
    }
}

// MARK: TaggedUserTableCellDelegate
extension TagPeopleViewController: TaggedUserTableCellDelegate {
    func didClickOnCross(sender: CustomButton) {
        if let taggedPeople = self.media[sender.section].taggedPeople,
            sender.row < taggedPeople.count {
            self.media[sender.section].taggedPeople?.remove(at: sender.row)
            if self.totalTaggedCount > 0 {
                totalTaggedCount -= 1
            }
            self.taggedUsersTableView.reloadData()
        }
    }
}

// MARK: TagAnotherPersonSectionDelegate
extension TagPeopleViewController: TagAnotherPersonSectionDelegate {
    func didTapOnAdd() {
        self.presentUsersListingToTag()
    }
}
