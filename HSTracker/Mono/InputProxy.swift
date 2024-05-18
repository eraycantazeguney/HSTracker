//
//  TestInputProxy.swift
//  HSTracker
//
//  Created by Francisco Moraes on 8/11/20.
//  Copyright © 2020 Benjamin Michotte. All rights reserved.
//

import Foundation

class InputProxy: MonoHandle, MonoClassInitializer {    
    static var _class: OpaquePointer?
    static var _constructor: OpaquePointer!
    static var _setTurn: OpaquePointer!
    static var _addSecretFromDbfid: OpaquePointer!
    static var _unitTest: OpaquePointer!
    
    static var _members = [String: OpaquePointer]()
    
    static func initialize() {
        if InputProxy._class == nil {
            InputProxy._class = MonoHelper.loadClass(ns: "BobsBuddy.Simulation", name: "Input")
            // methods
            InputProxy._constructor = MonoHelper.getMethod(InputProxy._class, ".ctor", 0)
            InputProxy._setTurn = MonoHelper.getMethod(InputProxy._class, "SetTurn", 1)
            InputProxy._addSecretFromDbfid = MonoHelper.getMethod(InputProxy._class, "AddSecretFromDbfIdHstracker", 2)
            InputProxy._unitTest = MonoHelper.getMethod(InputProxy._class, "UnitTestCopyableVersion", 0)
            
            // fields
            initializeFields(fields: [ "DamageCap", "Anomaly" ])
            
            // properties
            initializeProperties(properties: [ "Player", "Opponent" ])
        }
    }
    
    override init() {
        super.init()
        
        let obj = MonoHelper.objectNew(clazz: InputProxy._class!)
        set(obj: obj)
        
        let inst = self.get()
        
        mono_runtime_invoke(InputProxy._constructor, inst, nil, nil)
    }
    
    required init(obj: UnsafeMutablePointer<MonoObject>?) {
        fatalError("init(obj:) has not been implemented")
    }
    
    func setTurn(value: Int32) {
        MonoHelper.setInt(obj: self, method: InputProxy._setTurn, value: value)
    }
    
    func addAvailableRaces(races: [Race]) {
        let field = mono_class_get_field_from_name(InputProxy._class, "availableRaces")
        let inst = get()
        let obj = mono_field_get_value_object(MonoHelper._monoInstance, field, inst)
        
        let clazz = mono_object_get_class(obj)
        let method = mono_class_get_method_from_name(clazz, "Add", 1)
        
        let params = UnsafeMutablePointer<UnsafeMutablePointer<Int>>.allocate(capacity: 1)
        
        let a = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        
        for i in 0..<races.count {
            let v = Race.allCases.firstIndex(of: races[i])
            
            a.pointee = v!
            params[0] = a
            
            _ = params.withMemoryRebound(to: UnsafeMutableRawPointer?.self, capacity: 1, {
                mono_runtime_invoke(method, obj, $0, nil)
            })
        }
        a.deallocate()
        params.deallocate()
    }
    
    func addSecretFromDbfid(id: Int32, target: MonoHandle) {
        MonoHelper.setIntMonoHandle(obj: self, method: InputProxy._addSecretFromDbfid, v1: id, v2: target)
    }
    
    func unitestCopyableVersion() -> String {
        let inst = self.get()
        
        let temp = MonoHandle(obj: mono_runtime_invoke(InputProxy._unitTest, inst, nil, nil))
        
        return MonoHelper.toString(obj: temp)
    }
    
    @MonoPrimitiveField(field: "DamageCap", owner: InputProxy.self)
    var damageCap: Int32
    
    @MonoHandleField(field: "Anomaly", owner: InputProxy.self)
    var anomaly: AnomalyProxy
    
    @MonoHandleProperty(property: "Player", owner: InputProxy.self)
    var player: PlayerProxy
    
    @MonoHandleProperty(property: "Opponent", owner: InputProxy.self)
    var opponent: PlayerProxy
}
