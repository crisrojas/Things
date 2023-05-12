//
//  AsyncForEach.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 14/03/2023.
//

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
