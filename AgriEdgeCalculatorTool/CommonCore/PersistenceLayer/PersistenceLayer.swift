//
//  PersistenceLayer.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/17/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

class PersistenceLayer: PersistenceContext {
    
    var realm: Realm
    
    var isRealmEmpty: Bool {
        return realm.isEmpty
    }
    
    required init(configuration: RealmConfigurationType = .basic) {
        var realmConfiguration = Realm.Configuration(
            // set the new schema version
            // this must be greater than the previously used version
            schemaVersion: 7)

        Realm.Configuration.defaultConfiguration = realmConfiguration
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
    
}

protocol PersistenceContext {
    var realm: Realm { get set }
    var isRealmEmpty: Bool { get }
    
    func create<T: Object>(_ object: T, completion: ((PersistenceResult<T>) -> Void)?)
    func save<T: Object>(_ object: T, completion: ((PersistenceResult<String>) -> Void)?)
    func saveAll<T: Object>(of objects: [T], completion: ((PersistenceResult<String>) -> Void)?)
    func cleanSaveAll<T: Object>(of objects: [T], completion: ((PersistenceResult<String>) -> Void)?)
    func update<T: Object>(_ object: T, updates: @escaping (T) -> Void, completion: ((PersistenceResult<String>) -> Void)?)
    func delete<T: Object>(_ object: T, completion: ((PersistenceResult<String>) -> Void)?)
    func deleteAll<T: Object>(of model: T.Type, completion: ((PersistenceResult<String>) -> Void)?)
    func fetch<T: Object>(_ model: T.Type, predicate: NSPredicate?, sortedBy keyPath: String?, ascending: Bool?) -> [T]?
    func emptyRealm(completion: ((PersistenceResult<String>) -> Void)?)
}

extension PersistenceContext {
    
    func create<T: Object>(_ object: T, completion: ((PersistenceResult<T>) -> Void)? = nil) {
                print("~3", object)
        do {
            try realm.write {
                realm.create(T.self, value: object, update: .all)
                completion?(.success(object))
            }
        } catch let error {
            completion?(.failure(.writeError("\(error)")))
        }
    }
    
    func save<T: Object>(_ object: T, completion: ((PersistenceResult<String>) -> Void)? = nil) {
        do {
            try realm.write {
                realm.add(object, update: .modified)
                completion?(.success("added \(object.description) to realm"))
            }
        } catch let error {
            completion?(.failure(.writeError("\(error)")))
        }
    }
    
    func saveAll<T: Object>(of objects: [T], completion: ((PersistenceResult<String>) -> Void)? = nil) {
        do {
            try realm.write {
                realm.add(objects, update: .modified)
                completion?(.success("added \(objects.description) to realm"))
            }
        } catch let error {
            completion?(.failure(.writeError("\(error)")))
        }
    }
    
    func cleanSaveAll<T: Object>(of objects: [T], completion: ((PersistenceResult<String>) -> Void)? = nil) {
        do {
            try realm.write {
                realm.delete(realm.objects(T.self))
                realm.add(objects, update: .modified)
                completion?(.success("deleted previous \(objects.description) to realm and added new \(objects.description) to realm"))
            }
        } catch let error {
            completion?(.failure(.writeError("\(error)")))
        }
    }

    func  update<T: Object>(_ object: T, updates: @escaping (T) -> Void, completion: ((PersistenceResult<String>) -> Void)? = nil) {
        do {
            try realm.write {
                updates(object)
                completion?(.success("updated \(object) in realm"))
            }
        } catch let error {
            completion?(.failure(.writeError("\(error)")))
        }
    }
    
    func delete<T: Object>(_ object: T, completion: ((PersistenceResult<String>) -> Void)? = nil) {
        do {
            try realm.write {
                realm.delete(object)
                completion?(.success("deleted \(object.description) from realm"))
            }
        } catch let error {
            completion?(.failure(.writeError("\(error)")))
        }
    }
    
    func deleteAll<T: Object>(of model: T.Type, completion: ((PersistenceResult<String>) -> Void)? = nil) {
        do {
            try realm.write {
                realm.delete(realm.objects(T.self))
                completion?(.success("deleted \(T.self)s from realm"))
            }
        } catch let error {
            completion?(.failure(.writeError("\(error)")))
        }
    }
    
    func fetch<T: Object>(_ model: T.Type, predicate: NSPredicate? = nil, sortedBy keyPath: String? = nil, ascending: Bool? = nil) -> [T]? {
        var results = realm.objects(T.self)
        
        if let predicate = predicate {
            results = results.filter(predicate)
        }
        
        if let keyPath = keyPath, let ascending = ascending {
            results = results.sorted(byKeyPath: keyPath, ascending: ascending)
        }
        
        return Array(results).isEmpty ? nil : Array(results)
    }
    
    func emptyRealm(completion: ((PersistenceResult<String>) -> Void)? = nil) {
        do {
            try realm.write {
                realm.deleteAll()
                completion?(.success("deleted all objects from realm"))
            }
        } catch let error {
            completion?(.failure(.writeError("\(error)")))
        }
    }
    
}

enum RealmConfigurationType {
    case basic
    case update
}

enum PersistenceResult<T> {
    case success(T)
    case failure(PersistenceError)
}

enum PersistenceError: Error {
    case writeError(String)
}
