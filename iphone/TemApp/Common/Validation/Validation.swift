//
//  Validation.swift
//  BottleDriver
//
//  Created by shilpa on 08/08/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation

///success and failure enum
enum Valid {
    case success
    case failure(String)
}

///The validation types that are to be checked
enum ValidationType {
    case email
    case phoneNo
    case password
    case firstName
    case lastName
    case address
    case emailOrPhone //this will be the case when the user either enters email or phone number in a text field
    case otp
    case newPassword
    case userName
    case optionalEmail
    case optionalPhone
}

///regex for the different validation typs
enum RegEx: String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+\\.[A-Za-z]{2,6}"
    case password = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!#$%&'()*+,-./:;<=>?@^_`{|}~])[A-Za-z\\d$@!#$%&'()*+,-./:;<=>?@^_`{|}~&]{8,}"
    case phoneNo = "[0-9]{8,16}" // PhoneNo 8-15 Digits
    case firstName = "[A-Za-z .-']{2,21}"
    case lastName = "[A-Za-z .-']{2,41}"
    case otp = "[0-9]{4}"
    case userName = "[A-Za-z]+[A-Za-z0-9._$@$!%*?&^#+:;<>|]*"//"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{2,}"
    case hashTag = "#[\\w]+"//"#[A-Za-z0-9]+"
    case mention = "@[\\w]+"
}

//Validate the input fields
class Validation: NSObject {
    public static let shared = Validation()
    
    func validate(values: (type: ValidationType, inputValue: String?)...) -> Valid {
        for valueToBeChecked in values {
            switch valueToBeChecked.type {
            case .email:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .email, emptyInputMessage: AppMessages.Email.loginEmptyEmail, invalidInputMessage: AppMessages.Email.invalidEmail) {
                    return tempValue
                }
            case .optionalEmail:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .email, emptyInputMessage: nil, invalidInputMessage: AppMessages.Email.invalidEmail) {
                    return tempValue
                }
            case .password:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .password, emptyInputMessage: AppMessages.Password.emptyLoginPassword, invalidInputMessage: AppMessages.SignUp.invalidPasswordFormat) {
                    return tempValue
                }
            case .phoneNo:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .phoneNo, emptyInputMessage: AppMessages.SignUp.enterPhoneNumber, invalidInputMessage: AppMessages.SignUp.invalidPhoneNumber) {
                    return tempValue
                }
            case .optionalPhone:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .phoneNo, emptyInputMessage: nil, invalidInputMessage: AppMessages.SignUp.invalidPhoneNumber) {
                    return tempValue
                }
            case .firstName:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .firstName, emptyInputMessage: AppMessages.SignUp.enterFirstName, invalidInputMessage: AppMessages.UserName.maxLengthFirstname) {
                    return tempValue
                }
            case .lastName:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .lastName, emptyInputMessage: AppMessages.SignUp.enterLastName, invalidInputMessage: AppMessages.UserName.maxLengthLastname) {
                    return tempValue
                }
            case .address:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: nil, emptyInputMessage: AppMessages.SignUp.enterAddressLine1, invalidInputMessage: AppMessages.SignUp.enterAddressLine1) {
                    return tempValue
                }
            case .emailOrPhone:
                if valueToBeChecked.inputValue == nil {
                    if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: nil, emptyInputMessage: AppMessages.Login.enterEmailOrPhoneNumber, invalidInputMessage: AppMessages.Login.enterEmailOrPhoneNumber) {
                        return tempValue
                    }
                }
                if let input = valueToBeChecked.inputValue, input.isEmpty {
                    if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: nil, emptyInputMessage: AppMessages.Login.enterEmailOrPhoneNumber, invalidInputMessage: AppMessages.Login.enterEmailOrPhoneNumber) {
                        return tempValue
                    }
                }
                if let input = valueToBeChecked.inputValue, input.containsOnlyNumbers() {
                    //phone number
                    if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .phoneNo, emptyInputMessage: AppMessages.PhoneNumber.empty, invalidInputMessage: AppMessages.SignUp.invalidPhoneNumber) {
                        return tempValue
                    }
                } else {
                    //email
                    if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .email, emptyInputMessage: AppMessages.Email.loginEmptyEmail, invalidInputMessage: AppMessages.Email.loginInValidEmail) {
                        return tempValue
                    }
                }
            case .otp:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .otp, emptyInputMessage: AppMessages.OTP.enterOTP, invalidInputMessage: AppMessages.OTP.invalidOTP) {
                    return tempValue
                }
            case .newPassword:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .password, emptyInputMessage: AppMessages.ResetPassword.enterNewPassword, invalidInputMessage: AppMessages.Password.invalidNewPassword) {
                    return tempValue
                }
            case .userName:
                if let tempValue = isValidString(inputText: valueToBeChecked.inputValue, regexForType: .userName, emptyInputMessage: "emptyUserName".localized, invalidInputMessage: AppMessages.SignUp.enterValidEmail) {
                    return tempValue
                }
            }
        }
        return .success
    }

     func isValidString(inputText text: String?, regexForType regex: RegEx?, emptyInputMessage emptyMessage: String?, invalidInputMessage invalidMessage: String) -> Valid? {
        if text == nil {
            if let emptyWarningMessage = emptyMessage {
               return .failure(emptyWarningMessage)
            }
        } else if let inputText = text {
            if inputText.isEmpty {
                if let emptyWarningMessage = emptyMessage {
                    return .failure(emptyWarningMessage)
                }
            }
            if let regex = regex,
                isValidRegEx(inputText, regex) != true {
                return .failure(invalidMessage)
            }
        }
        return nil
    }
    
    func isValidRegEx(_ testStr: String, _ regex: RegEx) -> Bool {
        let stringTest = NSPredicate(format:"SELF MATCHES %@", regex.rawValue)
        let result = stringTest.evaluate(with: testStr)
        return result
    }
}
