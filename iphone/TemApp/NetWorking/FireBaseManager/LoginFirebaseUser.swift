//
//  LoginUser.swift
//
//  Created by narinder on 18/07/16.
//  Copyright © 2016 Capovela LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseAnalytics
import FirebaseInstanceID

@objc class LoginFirebaseUser: NSObject {
    

    /**
     Create Firebase user
     
     - parameter email:    guest email
     - parameter password: guest phone number
     */
  
    /**
     Firebase user  signin
     
     - parameter email:    guest email
     - parameter password: guest phone number
     */
  static func signIn(email : String, password:String, success: @escaping (_ loggedIn: String?, _ error: DIError) -> ()) {
       DILog.print(items: email,password)
       let emailForFirebase = email+"@gmail.com"
        Auth.auth().signIn(withEmail: emailForFirebase, password: password) { (user, error) in
          
          if let error = error {
               DILog.print(items: error.localizedDescription)
            
            Auth.auth().createUser(withEmail: emailForFirebase, password: password) { (user, error) in
              if let error = error {
               DILog.print(items: error.localizedDescription)
                success(nil, DIError.unKnowError())

                return
              }
              success("logged in", DIError.nilData())

              //            self.setDisplayName(user: user!)
            }
}
            else{
              
//              setAppState(user: user)

            success("logged in", DIError.nilData())
              return
            }
        }
    }
  
     
}
