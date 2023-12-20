//
//  AppUpdater.swift
//  BaseProject
//
//  Created by Aj Mehra on 25/04/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation

enum AppUpdateStatus {
    case available(updateType: AppUpdateType)
	case none
	case error
}

enum AppUpdateType {
    case normal, forceUpdate
}

class AppManager: DIWebLayer {

	// MARK: Singleton Instance
	//static let shared = AppManager()
    let update = true

	// MARK: Private Initializer
//    private override init() {
//	}

	func isFreshInstall() -> Bool {
		if Defaults.shared.get(forKey: .firstLaunch) != nil {
			return false
		}else {
			Defaults.shared.set(value: true, forKey: .firstLaunch)
			return true
		}
	}
    
    func checkNewUpdate(success: @escaping (_ status: AppUpdateStatus) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method: .get, function: Constant.SubDomain.checkAppUpdate, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                if let updateAvailable = data["isUpdate"] as? Int {
                    if updateAvailable == 1 {
                        //means update available
                        if let forceUpdate = data["isForceUpdate"] as? Int,
                            forceUpdate == 1 {
                            //force update
                            success(.available(updateType: .forceUpdate))
                        } else {
                            //normal update
                            success(.available(updateType: .normal))
                        }
                    } else {
                        success(.none)
                    }
                }
            }
        }) { (_) in
            
        }
    }
  
	// MARK: Methods
	// MARK: .......Public Methods

	/// This method will check whether a new version for the application is available or not
	///
	/// - Parameter success: success block contains status and track URL for app. 
	///   true:- there is an update for app
	///	  false:- may be there is some error or update is not available
	func isUpgradeAvailable(success: @escaping (_ status: AppUpdateStatus, _ trackURL: URL?, _ error:DIError?) -> Void) -> Void {
		guard let request = createAppUdateRequest().0 else {
			//Unable to create Request
			success(.error, nil, createAppUdateRequest().1)
			return
		}
		URLSession.shared.dataTask(with: request) { (data, _, _) in
			DispatchQueue.main.async {
				self.parseData(data: data, success: { (status, url, tempError) in
					success(status, url, tempError)
				})
			}
		}.resume()
	}

	// MARK: ......Private Method

	/// This Method is used to create the Request for checking whether a new version for application is avaiable on AppStore
	///
	/// - Returns: A valid URLRequest or nil
	private func createAppUdateRequest() -> (URLRequest?, DIError?) {
		//1. Get info dictionary from main bundle
		guard let infoDictionary = Bundle.main.infoDictionary else {
			//Unable to get info dictionary.
			return (nil,DIError.invalidAppInfoDictionary())
		}
		//2. Get app identifier from info dictionary
		guard let appID = infoDictionary["CFBundleIdentifier"] as? String else {
			//Unable to get App Identifier.
			return (nil,DIError.missingKey())
		}
		//3. Create URL
		guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=" + appID) else {
			//Unable to create a valid Url.
			return (nil, DIError.invalidUrl())
		}
		//4. Create Request
		var request: URLRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 150)
		request.httpMethod = "GET"
		return (request, nil)
	}


	/// This method will parse the data fetch form app store
	///
	/// - Parameters:
	///   - data: data from app store.
	private func parseData(data:Data?, success: (_ status: AppUpdateStatus, _ trackURL: URL?, _ error:DIError?) -> Void) -> Void {
		guard let tempData = data else {
			//Data is getting nil form server
			success(.error, nil, DIError.invalidData())
			return
		}
		do {
			guard let lookupDictionary = try JSONSerialization.jsonObject(with: tempData, options: .mutableLeaves) as? [String: Any] else {
				//Data is not in dictionary format
				success(.error, nil, DIError.invalidJSON())
				return
			}
			if lookupDictionary.isEmpty {
				//No Data coming from server
				success(.error, nil, DIError.nilData())
				return
			}
			guard let infoDictionary = Bundle.main.infoDictionary else {
				//Unable to get info dictionary.
				success(.error, nil, DIError.invalidAppInfoDictionary())
				return
			}
			if let resultCounter = lookupDictionary["resultCount"] as? NSNumber, resultCounter == 1 {
				guard let results = lookupDictionary["results"] as? NSArray , results.count > 0 else {
					//Either results key doesn't exit or result is empty
					success(.error, nil, DIError.nilData())
					return
				}
				guard let dataDictionary = results.firstObject as? NSDictionary else {
					//Data is not in dictionary format
					success(.error, nil, DIError.invalidData())
					return
				}
				let appStoreVersion = dataDictionary["version"] as? String
				let currentVersion  = infoDictionary["CFBundleShortVersionString"] as? String
				if currentVersion != nil && appStoreVersion != nil {
					if appStoreVersion!.compare(currentVersion!, options:.numeric) == .orderedDescending {
						if let appstoreURL = dataDictionary["trackViewUrl"] as? String {
                            success(.available(updateType: .normal), URL(string:appstoreURL), nil)
						}else {
							success(.available(updateType: .normal), nil, nil)
						}
						return

					}else {
						//There is no update for current version.
						success(.none, nil, nil)
						return
					}

				}else {
					// Either result counter is not string or it's value is not equal to 1
					success(.error, nil, DIError.missingKey())
					return
				}
			}else{
				// Either result counter is not string or it's value is not equal to 1
				success(.error, nil, DIError.missingKey())
				return
			}
		} catch {
			//invalid JSON
			success(.error, nil, DIError.invalidJSON())
			return
		}
	}

}
