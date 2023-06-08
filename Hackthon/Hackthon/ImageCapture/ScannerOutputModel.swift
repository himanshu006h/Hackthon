//
//  ScannerOutputModel.swift
//  Flamingo
//
//  Created by Himanshu Saraswat on 03/05/23.
//

import Foundation
/// Scanner Output model: Provide image and cropped image data.
public struct ScannerOutputModel {
    public let state: DocumentState
    public let documentData: Data?
    public var step: Int = 1
    
    public init(state: DocumentState, documentData: Data?, step: Int = 1) {
        self.state = state
        self.documentData = documentData
        self.step = step
    }
}
