//
//  IntegrationConfiguration.swift
//  Pods
//
//  Created by cdg on 2/11/21.
//

import Foundation

public class IntegrationConfiguration: NSObject {
    let enablePlayheadNormalization: Bool
    
    public init(enablePlayheadNormalization: Bool) {
        self.enablePlayheadNormalization = enablePlayheadNormalization
    }
}
