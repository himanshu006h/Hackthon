//
//  ScannerModel.swift
//  Flamingo
//
//  Created by Himanshu Saraswat on 02/05/23.
//

import Foundation
/// Input model to drive scanner component.
public struct ScannerModel {
    public let title: String?
    public let subtitle: String?
    public let state: DocumentState
    public let isFlashEnable: Bool
    public let isCaptureEnable: Bool
    public var step: Int
    
    public init(title: String?,
                subtitle: String?,
                state: DocumentState = .capture,
                isFlashEnable: Bool = true,
                isCaptureEnable: Bool = true,
                step: Int = 1) {
        self.title = title
        self.subtitle = subtitle
        self.state = state
        self.isFlashEnable = isFlashEnable
        self.isCaptureEnable = isCaptureEnable
        self.step = step
    }
}
