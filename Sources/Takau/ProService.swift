//
//  ProService.swift
//  Takau
//
//  Created by ikhwan on 04/05/25.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
class ProService: ObservableObject {
    @AppStorage("hasPro") var hasPro: Bool = false
}
