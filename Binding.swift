//
//  Binding.swift
//  Student Swift Colors
//
//  Created by Zack Wilson on 2/5/24.
//

import SwiftUI

extension Binding {
    func unwrap<Wrapped>(or defaultValue: Wrapped) -> Binding<Wrapped> where Value == Wrapped? {
        return Binding<Wrapped>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

