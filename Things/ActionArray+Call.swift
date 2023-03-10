//
//  VoidAction+Call.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

extension [() ->()] {func call() {self.forEach{$0()}}}
