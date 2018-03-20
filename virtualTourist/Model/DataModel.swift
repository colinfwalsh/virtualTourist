//
//  DataModel.swift
//  virtualTourist
//
//  Created by Colin Walsh on 3/20/18.
//  Copyright © 2018 Colin Walsh. All rights reserved.
//

import Foundation
import CoreData

class DataModel {
    let persistentContainer: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()->Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
