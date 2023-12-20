//
//  PhoneContact.swift
//  PhoneContact
//
//  Created by Narinder Singh on 03/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import ContactsUI


enum ContactsFilter {
    case none
    case mail
    case phoneNumber
}

protocol PhoneContactProtocol {
    func fetchContacts(filter: ContactsFilter,shouldShowAlertForPermission:Bool) -> [ContactModel]
}

extension PhoneContactProtocol {
    
    private func getContacts(filter: ContactsFilter = .none) -> [CNContact] {
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            //            Debug.Log(message: "Error fetching containers") // you can use print()
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                //                Debug.Log(message: "Error fetching containers")
            }
        }
        return results
    }
    
    
    
    func fetchContacts(filter: ContactsFilter,shouldShowAlertForPermission:Bool) -> [ContactModel] {
        // array of PhoneContact(It is model find it below)
        var phoneContacts = [ContactModel]()
        
        phoneContacts.removeAll()
        var allContacts = [ContactModel]()
        
        requestAccess { (access) in
            
            if (access) { //If User has permission...
                
                for contact in self.getContacts(filter: filter) {
                    allContacts.append(ContactModel(contact: contact))
                }
                var filterdArray = [ContactModel]()
                if filter == .mail {
                    filterdArray = allContacts.filter({ $0.email.count > 0 }) // getting all email
                } else if filter == .phoneNumber {
                    filterdArray = allContacts.filter({ $0.phoneNumber.count > 0 })
                } else {
                    filterdArray = allContacts
                }
                
                phoneContacts.append(contentsOf: filterdArray)
                
            } else {
                if (shouldShowAlertForPermission) {
                    Utility.showAlert(withTitle: "Tem", message: "Tem app requires access to your Phone contacts for Friends Suggestion",okayTitle: "Settings", cancelTitle: "Cancel",okCall: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL)
                    }, cancelCall: {
                        print("Cancel")
                    })
                }
            }
        }
       
        return phoneContacts
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            print("Denied")
            completionHandler(false)
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        @unknown default:
            break
        }
    }
}
