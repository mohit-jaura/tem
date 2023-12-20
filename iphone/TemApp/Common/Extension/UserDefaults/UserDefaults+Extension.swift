//
//  UserDefaults+Extension.swift
//  TemApp
//
//  Created by Ram on 2020-04-27.
//

import Foundation

extension UserDefaults {
    
    func save<T:Encodable>(customObject object: T, inKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: key)
        }
    }
    
    func retrieve<T:Decodable>(object type:T.Type, fromKey key: String) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(type, from: data) {
                return object
            }else {
                print("Couldnt decode object")
                return nil
            }
        }else {
            print("Couldnt find key")
            return nil
        }
    }

    class func CTDefault(setIntegerValue integer: Int , forKey key : String){
        UserDefaults.standard.set(integer, forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func CTDefault(setObject object: Any , forKey key : String){
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func CTDefault(setValue object: Any , forKey key : String){
        UserDefaults.standard.setValue(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func CTDefault(setBool boolObject:Bool  , forKey key : String){
        UserDefaults.standard.set(boolObject, forKey : key)
        UserDefaults.standard.synchronize()
    }
    class func CTDefault(integerForKey  key: String) -> Int{
        let integerValue : Int = UserDefaults.standard.integer(forKey: key) as Int
        UserDefaults.standard.synchronize()
        return integerValue
    }
    class func CTDefault(objectForKey key: String) -> Any {
        let object  = UserDefaults.standard.object(forKey: key)
        if let object = object {
            UserDefaults.standard.synchronize()
            return object
        } else {
            UserDefaults.standard.synchronize()
            return ""
        }
    }
    class func CTDefault(valueForKey  key: String) -> Any {
        let value  = UserDefaults.standard.value(forKey: key)
        if let value = value {
            UserDefaults.standard.synchronize()
            return value
        } else {
            return ""
        }

    }
    class func getSavedData(_ key: String) -> Any? {
        if  let value  = UserDefaults.standard.value(forKey: key) {
            UserDefaults.standard.synchronize()
            return value
        }
            return nil
    }


    class func CTDefault(boolForKey  key : String) -> Bool {
        let booleanValue : Bool = UserDefaults.standard.bool(forKey: key) as Bool
        UserDefaults.standard.synchronize()
        return booleanValue
    }

    class func CTDefault(removeObjectForKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }



    class func CTDefault(setArchivedDataObject object: Any! , forKey key : String) {
        if let object = object {

            //                let data : NSData? = NSKeyedArchiver.archivedData(withRootObject: object) as NSData?
            if let data =  try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)  {
                UserDefaults.standard.set(data, forKey: key)
                UserDefaults.standard.synchronize()
            }
        }

    }
    class func CTDefault(getUnArchiveObjectforKey key: String) -> Any {
        //var objectValue : Any?
        if  let storedData  = UserDefaults.standard.object(forKey: key) as? Data {
            if let objectValue   =   try? NSKeyedUnarchiver.init(forReadingFrom: storedData) {
                UserDefaults.standard.synchronize()
                return objectValue
            }

            //  let objectValue   =  NSKeyedUnarchiver.unarchiveObject(with: storedData)
            //                if (objectValue != nil)  {
            //                    return objectValue!
            //
            //                }else{
            //                    UserDefaults.standard.synchronize()
            //                    return ""

            //                }
            //            }else{
            //                //objectValue = ""
            //                return ""
            //            }
        }
        return ""
    }
    
}
