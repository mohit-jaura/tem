//
//  DocumentManager.swift
//
//  Created by Dhiraj on 20/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit

class DocumentManager: NSObject {
    
    static let shared = DocumentManager()
    var fileManager:FileManager?
 
    
    override init() {
        fileManager = FileManager.default
    }
    
    /// Save the image or video into document directory
    ///
    /// - Parameter fileData: filedata as Data
    func saveDataToDocumentDirectory(fileData:Data,fileName:String) -> Bool {
        
        if let documentDirectory = getDocumentDirectory(){
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            DILog.print(items: "Path is \(fileURL)")
            
            do {
                try fileData.write(to: fileURL)
            }
            catch {
                return false
            }
            
            return true
        }
        return false
      
    }
    func getDocumentDirectory() -> URL? {
    
        let documentDirectory:URL?
        do {
             documentDirectory = try fileManager?.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
         //   print("document directory url: \(documentDirectory)")
        } catch {
            DILog.print(items:error)
            return nil
        }
        return documentDirectory
    
    }
    
    func deleteFromDocumentDirectory(atPath path: String) {
        if let documentDirectory = getDocumentDirectory() {
            let fileUrl = documentDirectory.appendingPathComponent(path)
            
            do {
                try fileManager?.removeItem(at: fileUrl)
            } catch(let error) {
                print("could not delete from document directory:- \(error)")
            }
        }
    }
}
