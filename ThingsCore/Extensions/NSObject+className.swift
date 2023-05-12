//
//  NSObject+className.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 14/03/2023.
//

import CoreData

extension NSObject {
    var className: String {
        String(describing: type(of: self))
    }
    
    class var className: String {
        String(describing: self)
    }
}
