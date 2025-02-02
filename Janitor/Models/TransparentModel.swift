//
//  TransparentModel.swift
//  Janitor
//
//  Created by Ky on 2024-09-27.
//

import Foundation

import SwiftData
import FunctionTools



protocol TransparentModel: PersistentModel {
    associatedtype BaseType
    
    var base: BaseType { get }
    
    init(_ base: BaseType)
}



extension ModelContext {
    func replaceTransparentModelsOfType<Value, ValueModel>(
        newValues: [Value],
        forModelType: ValueModel.Type = ValueModel.self,
        onEachChange: Callback<SimpleRecordChange<ValueModel>> = null)
    throws
    where ValueModel: TransparentModel,
          ValueModel.BaseType == Value
    {
        try transaction {
            try fetch(.init(predicate: #Predicate<ValueModel> { _ in true }))
                .forEach { existingRecord in
                    delete(existingRecord)
                    onEachChange(.remove(existingRecord))
                }
            
            newValues.map(ValueModel.init)
                .forEach { newRecord in
                    insert(newRecord)
                    onEachChange(.insert(newRecord))
                }
        }
        
        try save()
    }
}



public enum SimpleRecordChange<Value> {
    case insert(Value)
    case remove(Value)
}
