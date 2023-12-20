//
//  ActiveTemsAndGoalsViewController+APIHandler.swift
//  TemApp
//
//  Created by Mohit Soni on 05/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation
extension ActiveTemsAndGoalsViewController {
    func getDataFromAPI() {
        self.showHUDLoader()
        switch screenSelection {
            case .tems:
                getTems()
            case .goals:
                getGoals()
            case .challengs:
                getChallenges()
        }
    }
    func getTems() {
        viewModal?.callActiveTemsAPI { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal?.error {
                self?.tableView.showEmptyScreen("No TĒMS Found!", isWhiteBackground: false)
                self?.showAlert(withMessage: error.message ?? "Something went wrong, Please try again after some time!")
                self?.reloadTableView()
            } else {
                if self?.viewModal?.temsModal?.count ?? 0 == 0 {
                    self?.tableView.showEmptyScreen("No TĒMS Found!", isWhiteBackground: false)
                } else {
                    self?.tableView.showEmptyScreen("", isWhiteBackground: false)
                }
                self?.reloadTableView()
            }
        }
    }
    func getGoals() {
        viewModal?.callActiveGoalsAPI { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal?.error {
                self?.tableView.showEmptyScreen("No GOALS Found!", isWhiteBackground: false)
                self?.showAlert(withMessage: error.message ?? "Something went wrong, Please try again after some time!")
                self?.tableView.reloadData()
            } else {
                if self?.viewModal?.goalsModal?.count ?? 0 == 0 {
                    self?.tableView.showEmptyScreen("No GOALS Found!", isWhiteBackground: false)
                } else {
                    self?.tableView.showEmptyScreen("", isWhiteBackground: false)
                }
                self?.reloadTableView()
            }
        }
    }
    func getChallenges() {
        viewModal?.callActiveChallengesAPI { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal?.error {
                self?.tableView.showEmptyScreen("No CHALLENGES Found!", isWhiteBackground: false)
                self?.showAlert(withMessage: error.message ?? "Something went wrong, Please try again after some time!")
                self?.reloadTableView()
            } else {
                if self?.viewModal?.challengesModal?.count ?? 0 == 0 {
                    self?.tableView.showEmptyScreen("No CHALLENGES Found!", isWhiteBackground: false)
                } else {
                    self?.tableView.showEmptyScreen("", isWhiteBackground: false)
                }
                self?.tableView.reloadData()
            }
        }
    }
}
