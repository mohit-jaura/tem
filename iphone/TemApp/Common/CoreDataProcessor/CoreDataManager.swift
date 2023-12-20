//
//  CoreDataManager.swift
//
//  Created by Dhiraj on 19/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit
import CoreData

enum Entity: String {
	case contactNumber = "ContactNumber"
}

class CoreDataManager: NSObject {

	static let shared = CoreDataManager()
	var fileManager: FileManager?
	var postInfo: Postinfo?
	var filesInfo: FilesInfo?
	var postAdress: PostAddress?
	var entityInfo: NSManagedObject?

	func saveData(of entity: String, object: Any) -> NSManagedObject {

		if #available(iOS 10, *) {
			entityInfo = NSEntityDescription.insertNewObject(forEntityName: entity, into: appDelegate.persistentContainer.viewContext)
		} else {
			entityInfo = NSEntityDescription.insertNewObject(forEntityName: entity, into: appDelegate.managedObjectContext!)
		}
		entityInfo?.saveDetailsInDB(object: object)
		appDelegate.saveContext(succes: {

		}) { (_) in

		}
		return entityInfo!
	}
	

	func getEntityData(with predicate: NSPredicate, of entityName: String) -> [Any] {

		var data: [Any] = []
		do {
			let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
			request.predicate = predicate
			if #available(iOS 10, *) {
				data = try appDelegate.persistentContainer.viewContext.fetch(request)
			} else {
				let data = try appDelegate.managedObjectContext?.fetch(request)
				return data!
			}
		} catch {
			DILog.print(items: "Error Occurred")
		}
		return data
	}
	


	func deleteData() {
        let isUploadedKey = Constant.CoreData.PostEntityKeys.isuploaded.rawValue
		let postPredicate = NSPredicate(format: "\(isUploadedKey) == %d || \(isUploadedKey) == %d ", 0, 1)
		let postInfoArr: [Postinfo] = CoreDataManager.shared.getEntityData(with: postPredicate, of: Constant.CoreData.postEntity) as! [Postinfo]
		for object in postInfoArr {

			if #available(iOS 10, *) {

				appDelegate.persistentContainer.viewContext.delete(object)

			} else {
				appDelegate.managedObjectContext?.delete(object)
			}
		}
        let fileIsUploadedKey = Constant.CoreData.FileEntityKeys.isuploaded.rawValue
		let filesPredicate = NSPredicate(format: "\(fileIsUploadedKey) == %d || \(fileIsUploadedKey) == %d ", 0, 1)
		let filesInfoArr: [FilesInfo] = CoreDataManager.shared.getEntityData(with: filesPredicate, of: Constant.CoreData.FileEntity) as! [FilesInfo]
		for object in filesInfoArr {

			if #available(iOS 10, *) {
				appDelegate.persistentContainer.viewContext.delete(object)
			} else {
				appDelegate.managedObjectContext?.delete(object)
			}
		}

		let addressPredicate = NSPredicate(format: "id != %@", "")
		let address: [PostAddress] = CoreDataManager.shared.getEntityData(with: addressPredicate, of: Constant.CoreData.AddressEntity) as! [PostAddress]
		for object in address {

			if #available(iOS 10, *) {
				appDelegate.persistentContainer.viewContext.delete(object)
			} else {
				appDelegate.managedObjectContext?.delete(object)
			}
		}
		appDelegate.saveContext(succes: {

		}) { (_) in

		}

	}
	
	func save(object: NSObject, forEntity entity: Entity) -> NSManagedObject {
		
		if #available(iOS 10, *) {
			entityInfo = NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: appDelegate.persistentContainer.viewContext)
		} else {
			entityInfo = NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: appDelegate.managedObjectContext!)
		}
		entityInfo?.saveDetailsInDB(object: object)
		appDelegate.saveContext(succes: {
			
		}) { (_) in
			
		}
		return entityInfo!
	}
	
	func fetch(with predicate: NSPredicate? = nil , forEntity entity: Entity) -> [Any]? {
		var data: [Any]?
		do {
			let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
			if let predicate = predicate {
				request.predicate = predicate
			}
			if #available(iOS 10, *) {
				data = try appDelegate.persistentContainer.viewContext.fetch(request)
			} else {
				data = try appDelegate.managedObjectContext?.fetch(request)
				
			}
		} catch {
			DILog.print(items: "Error Occurred")
		}
		return data
	}
	func delete(object:NSManagedObject){
		var context : NSManagedObjectContext?
		if #available(iOS 10.0, *) {
			context = appDelegate.persistentContainer.viewContext
		} else {
			context = appDelegate.managedObjectContext
		}
		context?.delete(object )
		appDelegate.saveContext(succes: { 
			
		}) { (_) in
			
		}
	}
	func update(object:NSManagedObject){
		appDelegate.saveContext(succes: {
			
		}) { (_) in
			
		}
	}
	func saveContext(){
		appDelegate.saveContext(succes: {
			
		}) { (_) in
			
		}
	}
}

extension CoreDataManager {
    /// save data in the managed object context other than the main
    ///
    /// - Parameter success: success block contains status and track URL for app.
    ///   viewContext: the managed object context in which the data is to be saved
    ///      entity:- name of the entity in the core data model
    /// object:- object to save in core data
    func saveDataInContext(viewContext: NSManagedObjectContext, entity: String, object: Any) -> NSManagedObject {
        entityInfo = NSEntityDescription.insertNewObject(forEntityName: entity, into: viewContext)
        entityInfo?.saveDetailsInDB(object: object)
        
        // Save all the tasks done in background to the view context and reset the taskContext to free the cache.
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error: \(error)\nCould not save Core Data context.")
            }
        }
        return entityInfo!
    }
    
    /// delete the entries from the database
    ///
    /// - Parameters:
    ///   - entityName: name of the entity to remove
    ///   - viewContext: managed object context
    ///   - predicate: filter operation if any
    func delete(entityName: String, fromContext viewContext: NSManagedObjectContext, predicate: NSPredicate? = nil) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let batchResult = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            if let deletedObjectIDs = batchResult?.result as? [NSManagedObjectID] {
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                    into: [appDelegate.persistentContainer.viewContext])
            }
        } catch(let error) {
            print("Error: \(error):- Could not batch delete existing records")
        }
    }
    
    /// save any of the changes in the context
    static func saveContext(viewContext: NSManagedObjectContext) {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch (let error) {
                print("Error in saving context \(error)")
            }
        }
    }
    
    /// get data from the database
    ///
    /// - Parameters:
    ///    - entityName: name of the data model entity
    ///    - predicate: predicate, if any, to filter the result
    ///    - completion: invoked on successfull fetching of the data from database
    ///    - data: result of the array type returned by the fetch request
    ///    - failure: error block invoked in case of error in fetching the records from database
    static func getOfflineSavedData(entityName: String, predicate: NSPredicate? = nil, completion: (_ data: [Any]) -> Void, failure: (_ error: Error) -> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        fetchRequest.predicate = predicate
        
        do {
            let result = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
            completion(result)
        } catch (let error) {
            print("error: \(error) ->  in fetching the saved offline data")
            failure(error)
        }
    }
}
