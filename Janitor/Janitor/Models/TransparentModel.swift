//
//  TransparentModel.swift
//  Janitor
//
//  Created by Ky on 2024-09-27.
//

import Foundation

import SwiftData



protocol TransparentModel: PersistentModel {
    associatedtype BaseType
    
    var base: BaseType { get }
    
    init(_ base: BaseType)
}



extension ModelContext {
    func replaceTransparentModelsOfType<Value, ValueModel>(newValues: [Value], forModelType: ValueModel.Type = ValueModel.self) throws
    where ValueModel: TransparentModel,
          ValueModel.BaseType == Value
    {
        
        try self.transaction {
            try self
                .fetch(.init(predicate: #Predicate<ValueModel> { _ in true }))
                .forEach(delete)
            
            let newModels = newValues.map(ValueModel.init)
            for newModel in newModels {
                self.insert(newModel)
            }
        }
        
        try self.save()
    }
}
