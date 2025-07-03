//
//  HubProxyAsyncProtocol.swift
//  SignalR-Swift
//
//  Created by Art on 03.07.2025.
//


protocol HubProxyAsyncProtocol {
    func on(eventName: String, handler: @escaping Subscription) async -> Subscription?
    func invoke(method: String, withArgs args: [Any]) async throws -> Any?
    func invokeEvent(eventName: String, withArgs args: [Any]) async
}

extension HubProxyAsyncProtocol where Self: HubProxyProtocol {
    func on(eventName: String, handler: @escaping Subscription) async -> Subscription? {
        return await withCheckedContinuation { continuation in
            continuation.resume(returning: on(eventName: eventName, handler: handler))
        }
    }
    
    func invoke(method: String, withArgs args: [Any]) async throws -> Any? {
        return try await withCheckedThrowingContinuation { continuation in
            invoke(method: method, withArgs: args) { (response: Any?, error: Error?) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: response)
                }
            }
        }
    }
    
    func invokeEvent(eventName: String, withArgs args: [Any]) async {
        await withCheckedContinuation { continuation in
            invokeEvent(eventName: eventName, withArgs: args)
            continuation.resume()
        }
    }
}
