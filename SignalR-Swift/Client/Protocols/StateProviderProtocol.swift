//
//  HubProxyProtocol 2.swift
//  SignalR-Swift
//
//  Created by Art on 03.07.2025.
//


protocol StateProviderProtocol: AnyObject {
    func getState(key: String) async -> Any?
    func setState(key: String, value: Any) async
}
