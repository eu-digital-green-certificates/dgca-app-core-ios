//
//  File.swift
//  
//
//  Created by Igor Khomiak on 19.01.2022.
//

import Foundation

/// A thread-safe array.
public class SyncDict<Element> {

    fileprivate let queue = DispatchQueue(label: "Wallet.Element.SyncDict", attributes: .concurrent)
    fileprivate var dict = Dictionary<String, Element>()
    
    public init() {
    }
}

// MARK: - Properties
public extension SyncDict {

    var resultDict: Dictionary<String, Element> {
        return dict
    }
    
    /// The number of elements in the array.
    var count: Int {
        var result = 0
        queue.sync { result = self.dict.count }
        return result
    }
 
    /// A Boolean value indicating whether the collection is empty.
    var isEmpty: Bool {
        var result = false
        queue.sync { result = self.dict.isEmpty }
        return result
    }
 
    /// A textual representation of the array and its elements.
    var description: String {
        var result = ""
        queue.sync { result = self.dict.description }
        return result
    }
}

// MARK: - Mutable
public extension SyncDict {
    
    /// Adds a new element at the end of the array.
    /// - Parameter element: The element to append to the array.
    func append( _ element: [String : Element]) {
        queue.async(flags: .barrier) {
            for (key, value) in element {
                self.dict.updateValue(value, forKey: key)
            }
        }
    }
    
    func update(value: Element, forKey key: String) {
        queue.async(flags: .barrier) {
            self.dict.updateValue(value, forKey: key)
        }
    }
    
    func value(forKey key: String) -> Element? {
        var result: Element?
        queue.sync { result = dict[key] }
        return result
    }
    
    /// Removes all elements from the array.
    /// - Parameter completion: The handler with the removed elements.
    func removeAll(completion: (([String: Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let elements = self.dict
            self.dict.removeAll()
            
            DispatchQueue.main.async {
                completion?(elements)
            }
        }
    }
}
