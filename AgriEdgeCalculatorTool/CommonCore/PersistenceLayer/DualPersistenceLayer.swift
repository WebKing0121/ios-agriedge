//
//  DualPersistenceLayer.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/20/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

class DualPersistenceLayer: PersistenceContext {
    
    var realm: Realm
    
    var isRealmEmpty: Bool {
        return realm.isEmpty
    }
    
    var shouldAddToUpdateRealm: Bool
    
    init(configuration: RealmConfigurationType = .basic, shouldAddToUpdateRealm: Bool = false) {
        
        // Perform Realm Migrations When Necessary
        // https://realm.io/docs/swift/latest/#migrations
        let config = Realm.Configuration(
            // set the new schema version
            // this must be greater than the previously used version
            schemaVersion: 7)
        
        Realm.Configuration.defaultConfiguration = config
        
        var realmConfiguration = Realm.Configuration()
        self.shouldAddToUpdateRealm = shouldAddToUpdateRealm
        
        switch configuration {
        case .basic:
            realmConfiguration = Realm.Configuration.defaultConfiguration
        case .update:
            realmConfiguration = Realm.Configuration.defaultConfiguration
            realmConfiguration.fileURL = realmConfiguration.fileURL!.deletingLastPathComponent().appendingPathComponent("update.realm")
        }
        
        do {
            try self.realm = Realm(configuration: realmConfiguration)
        } catch let error {
            log(error: "realm creation error \(error)")
            fatalError()
        }
    }
    
    func save<T: Object>(_ object: T, completion: ((PersistenceResult<String>) -> Void)? = nil) {
        print("~2", object)
        PersistenceLayer().save(object) { result in
            switch result {
            case .success:
                if !self.shouldAddToUpdateRealm {
                    completion?(.success("added \(object.description) to default realm"))
                }
            case .failure:
                break
            }
        }
        
        if shouldAddToUpdateRealm {
            PersistenceLayer(configuration: .update).create(object) { result in
                switch result {
                case .success:
                    completion?(.success("added \(object.description) to update realm"))
                case .failure:
                    break
                }
            }
        }
    }
    
    func saveAll<T: Object>(of objects: [T], completion: ((PersistenceResult<String>) -> Void)? = nil) {
        PersistenceLayer().saveAll(of: objects) { result in
            switch result {
            case .success:
                completion?(.success("added \(objects.description) to realm"))
            case .failure:
                break
            }
        }
        
        if shouldAddToUpdateRealm {
            for object in objects {
                PersistenceLayer(configuration: .update).create(object) { result in
                    switch result {
                    case .success:
                        print("saved to update realm")
                    case .failure:
                        break
                    }
                }
            }
        }
    }
    
    func cleanSaveAll<T: Object>(of objects: [T], completion: ((PersistenceResult<String>) -> Void)? = nil) {
        PersistenceLayer().cleanSaveAll(of: objects) { result in
            switch result {
            case .success:
                completion?(.success("added \(objects.description) to realm"))
            case .failure:
                break
            }
        }
        
        if shouldAddToUpdateRealm {
            for object in objects {
                PersistenceLayer(configuration: .update).create(object) { result in
                    switch result {
                    case .success:
                        print("saved to update realm")
                    case .failure:
                        break
                    }
                }
            }
        }
    }
    
}
