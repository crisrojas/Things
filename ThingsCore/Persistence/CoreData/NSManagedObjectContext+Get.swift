//
//  NSManagedObjectContext+Get.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//
import CoreData

extension NSManagedObjectContext {
    
    func get<T: NSManagedObject>(id: UUID) async throws -> T? {
        try await self.perform { [weak self] in
            let request = NSFetchRequest<T>(entityName: T.className)
            request.predicate = NSPredicate(
                format: "id == %@",
                id as CVarArg
            )
            
            return try self?.fetch(request).first
        }
    }
    
    func get<E, R>(request: NSFetchRequest<E>) async throws -> [R] where E: NSManagedObject, E: ToSafeObject, R == E.SafeType {
        try await self.perform { [weak self] in
            try self?.fetch(request).compactMap { try $0.safeObject() } ?? []
        }
    }
    
    @discardableResult
    func delete<T: NSManagedObject>
    (_ entityName: String, id: UUID) async throws -> T? {
        try await self.perform { [weak self] in
            let request = NSFetchRequest<T>(entityName: entityName)
            request.predicate = NSPredicate(
                format: "id == %@",
                id as CVarArg
            )
            request.fetchLimit = 1
            
            guard let object = try self?.fetch(request).first else {
                throw CoreDataError.entityNotFound
            }
            
            self?.delete(object)
            return nil
        }
    }
}
