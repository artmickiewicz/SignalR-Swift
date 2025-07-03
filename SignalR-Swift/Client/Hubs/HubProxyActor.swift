//
//  HubProxyActor.swift
//  SignalR-Swift
//
//  Created by Art on 03.07.2025.
//

import Foundation

public actor HubProxyActor: HubProxyAsyncProtocol, StateProviderProtocol {
    private weak var connection: HubConnectionProtocol?
    private let hubName: String
    private var subscriptions = [String: Subscription]()
    private var state = [String: Any]()

    // MARK: - Init

    public init(connection: HubConnectionProtocol, hubName: String) {
        self.connection = connection
        self.hubName = hubName
    }

    // MARK: - Subscribe

    public func on(eventName: String, handler: @escaping Subscription) async -> Subscription? {
        guard !eventName.isEmpty else {
            NSException.raise(.invalidArgumentException, format: NSLocalizedString("Argument eventName is null", comment: "null event name exception"), arguments: getVaList(["nil"]))
            return nil
        }
        
        return self.subscriptions[eventName] ?? self.subscriptions.updateValue(handler, forKey: eventName) ?? handler
    }

    public func invokeEvent(eventName: String, withArgs args: [Any]) async {
        if let subscription = self.subscriptions[eventName] {
            subscription(args)
        }
    }

    // MARK: - Publish

    public func invoke(method: String, withArgs args: [Any]) async throws -> Any? {
        guard !method.isEmpty else {
            NSException.raise(.invalidArgumentException,
                              format: NSLocalizedString("Argument method is null", comment: "null event name exception"),
                              arguments: getVaList(["nil"]))
            return nil
        }
        
        guard let connection = self.connection else {
            throw NSError(domain: "HubProxy", code: -1, userInfo: [NSLocalizedDescriptionKey: "Connection is not available"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            var didFinish = false
            
            let callbackId = connection.registerCallback { result in
                guard !didFinish else { return }
                didFinish = true
                
                guard let hubResult = result else {
                    continuation.resume(returning: nil)
                    return
                }
                hubResult.state?.forEach { (key, value) in self.state[key] = value }
                continuation.resume(returning: hubResult.result)
            }
            
            let hubData = HubInvocation(callbackId: callbackId,
                                        hub: self.hubName,
                                        method: method,
                                        args: args,
                                        state: self.state)
            
            guard let json = hubData.toJSONString() else {
                continuation.resume(throwing: NSError(domain: "HubProxy", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data serialization error"]))
                return
            }
            
            connection.send(object: json) { sendResult, sendError in
                guard !didFinish else { return }
                
                if let error = sendError {
                    didFinish = true
                    continuation.resume(throwing: error)
                } else if let sendResult = sendResult {
                    didFinish = true
                    continuation.resume(returning: sendResult)
                } else {
                    // Wait for registerCallback
                }
            }
        }
    }
    
    public func getState(key: String) async -> Any? {
        return state[key]
    }

    public func setState(key: String, value: Any) async {
        state[key] = value
    }
}
