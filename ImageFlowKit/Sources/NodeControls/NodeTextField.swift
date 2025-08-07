//
//  NodeTextField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

#if os(macOS)
public typealias NodeTextField = NodeTextFieldAppKit
#endif

#if os(iOS)
public typealias NodeTextField = NodeTextFieldUIKit
#endif
