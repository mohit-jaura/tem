//
//  ErrorMessage.swift
//  ImenuFr
//
//  Created by Aj Mehra on 05/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation

enum DIErrorMessage: String {
	case invalidFeedbackMessage = "Please enter a valid description between 3 – 300 characters."
	case invalidFeedbackIssue = "Please select the issue form the list."
	case invalidEmail = "Please enter valid email."
	case invalidSubject = "Please provide a valid subject for issue between 3 – 50 characters."
	case unknown = "Sorry, something went wrong. We're working on getting this fixed as soon as we can."

}

struct ErrorMessage {
	struct Unknown {
		static let title = "OOPS".localized
		static let message = "Sorry, something went wrong. We're working on getting this fixed as soon as we can.".localized
	}
	struct NoResponse {
		static let title = "OOPS".localized
		static let message = "Sorry, something went wrong. We're working on getting this fixed as soon as we can.".localized
	}
	struct NoNetwork {
		static let title = "OOPS".localized
		static let message = "The Internet connection appears to be offline.".localized
	}
	struct InvalidUrl {
		static let title = "Invalid URL".localized
		static let message = "Sorry, something went wrong. We're working on getting this fixed as soon as we can.".localized
	}
	struct Facebook {
		struct Cancelled {
			static let title = "Cancelled".localized
			static let message = "User has cancel the facebook login request".localized
		}
		struct EmailRequestDenied {
			static let title = "Permission Denied".localized
			static let message = "User has not provided access for email address".localized
		}
		struct NoAccountFind {
			static let title = "No Facebook Account Found".localized
			static let message = "Please install the Facebook application or login with your Facebook account on setting".localized
		}
	}
	struct MissingKey {
		static let title = "Key Missing".localized
		static let message = "Sorry, something went wrong. We're working on getting this fixed as soon as we can.".localized
	}
	struct LoadingData {
		static let title = "".localized
		static let message = "Loading...".localized
	}
	struct Twitter {
		struct NoEmailRegister {
			static let title = "No Email Found".localized
			static let message = "There is no email address is assoicated with this account, Please resgister or login with other option".localized
		}
		struct NoAccountFind {
			static let title = "No Twitter Account Found".localized
			static let message = "Please install the Twitter application or login with your Twitter account on setting".localized
		}

	}
	struct Name {
		struct EmptyName {
			static let title = "Warning".localized
			static let message = "Please enter name".localized
		}
		struct InvalidName {
			static let title = "Warning".localized
			static let message = "Please enter a valid name between 4 – 15 characters.".localized
		}

	}
	struct Address {
		static let empty = "Please enter address".localized
		static let invalid = "Please enter a valid address between 4 – 15 characters.".localized
		
	}
	struct Email {

		struct EmptyEmail {

			static let title = "Warning".localized
			static let message = "Please enter your email".localized
		}

		struct InvalidEmail {

			static let title = "Warning".localized
			static let message = "Please enter a valid email".localized
		}
	}

	static let invalidSubject = "Please enter a valid subject between 3 – 50 characters.".localized
	struct SpottaleName {
		struct EmptyName {
			static let title = "Warning".localized
			static let message = "Please enter spottale title".localized
		}
		struct InvalidName {
			static let title = "Warning".localized
			static let message = "Please enter a valid spottale name between 4 – 15 characters with one space allowed".localized
		}
	}
	struct SpottaleDescription {
		struct EmptyName {
			static let title = "Warning".localized
			static let message = "Please enter spottale description".localized
		}
		struct InvalidName {
			static let title = "Warning".localized
			static let message = "Please enter a valid spottale description between 4 – 200 characters".localized
		}
	}
	struct SpottaleLocation {
		struct EmptyLocation {
			static let title = "Warning".localized
			static let message = "Spottale location is required.Go to settings & enable location".localized
		}
	}

	struct Password {

		struct EmptyPasswordd {
			static let title = "Warning".localized
			static let message = "Please enter your password".localized
		}

		struct InvalidPassword {

			static let title = "Warning".localized
			static let message = "invalidPassword".localized
		}
		struct ConfirmEmpty {
			static let title = "Warning".localized
			static let message = "Please enter confirm password".localized
		}

		struct ConfirmInvalid {

			static let title = "Warning".localized
			static let message = "invalidPassword".localized
		}
		struct UnMatch {

			static let title = "Warning".localized
			static let message = "New password & Confirm password does not match".localized
		}
	}
	struct Policy {
		static let message = "Please accept our terms and conditions".localized
	}
	struct Phone {

		struct EmptyCountryCode {

			static let title = "Warning".localized
			static let message = "Please enter a country code".localized
		}
		struct InvalidCountryCode {

			static let title = "Warning".localized
			static let message = "Please enter valid country code".localized
		}

		struct EmptyPhone {
			static let title = "Warning".localized
			static let message = "Please enter phone number".localized
		}

		struct InvalidPhone {

			static let title = "Warning".localized
			static let message = "Please enter valid phone number".localized
		}
	}

	struct EmailOrPhone {

		struct Empty {
			static let title = "Warning".localized
			static let message = "Please enter a Email/Phone Number.".localized
		}

		struct Invalid {
			static let title = "Warning".localized
			static let message = "Please enter a valid Email/Phone Number.".localized
		}
	}
	struct OTP {
		static let nilOTPMsg = "Please enter a OTP".localized
		static let otpOnPhone = "otpOnPhone".localized
		static let otpOnEmail = "otpOnEmail".localized
		static let wrongOtp = "wrongOtp".localized
		static let invalidOTP = "Please enter a valid OTP within 6 charecters".localized
	}
	struct CameraPermissions {

		static let title = "Warning".localized
		static let message = "You don't have permission to access camera.'Go to settings' to update permissions".localized
	}
	struct VideoSize {

		static let title = "Warning".localized
		static let message = "Please capture a video less than 15 seconds".localized
	}
	struct Post {
		struct Offline {
			static let save = "Sorry! You can't store more than 10 posts offline. Please wait until you are online again and one or more offline posts have been published.".localized
		}
        static let error = "Oops, something went wrong...".localized
        static let cannotUpload = "Couldn't upload new post".localized
	}

	struct DocumentDirectory {

		static let title = "Warning"
		static let message = "Unable to save"

	}


}
