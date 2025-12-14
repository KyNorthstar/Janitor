//
//  AsyncSequence + onReceive.swift
//  Janitor
//
//  Created by Ky on 2025-10-28.
//

import Combine
import SwiftUI



public extension View {
    /// Run `perform` on each element of an `AsyncSequence`, including ones that arrive in the future
    /// 
    /// - Parameters:
    ///   - sequence: The sequence to iterate over and act on
    ///   - perform:  The action to take on each element
    func onReceive<Sequence, Element>(_ sequence: Sequence, perform: @escaping (Element) async -> Void) -> some View
    where Sequence: AsyncSequence,
            Element == Sequence.Element
    {
        modifier(AsyncSequenceReceiver<Sequence, Element>(sequence, onReceive: perform))
    }
}



private struct AsyncSequenceReceiver<Sequence, Element>: ViewModifier
where Sequence: AsyncSequence,
      Element == Sequence.Element
{
    private let sequence: Sequence
    private let onReceive: (Element) async -> Void
    
    
    @State
    private var cancellables: Set<AnyCancellable> = []
    
    
    init(_ sequence: Sequence, onReceive: @escaping (Element) async -> Void) {
        self.sequence = sequence
        self.onReceive = onReceive
    }
    
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                sequence.sink { value in
                    await onReceive(value)
                }
                .store(in: &cancellables)
            }
    }
}



public extension AsyncSequence {
    /// Asynchronously run the given function on each element of this sequence, including ones that arrive in the future.
    ///
    /// The process of iterating across this sequence begins immediately, before this function returns, and continues asynchronously after it returns.
    ///
    /// You may cancel the returned value to stop processing this sequence.
    ///
    /// - Parameter body: Asynchronously runs for each element in this sequence, unless cancelled
    /// - Returns: A value that you can cancel at any time to stop this from running.
    func sink(_ body: @escaping (Element) async -> Void) -> any Cancellable {
        let cancellable = AsyncCancellable()
        Task {
            var iterator = self.makeAsyncIterator()
            while let value = try? await iterator.next(),
                  !cancellable.isCancelled,
                  !Task.isCancelled
            {
                await body(value)
            }
        }
        return cancellable
    }
}



final actor AsyncCancellable: Cancellable {
    
    //unsafe: Race conditions are desirable here actually
    nonisolated(unsafe) public private(set) var isCancelled = false
    
    
    deinit {
        cancel()
    }
    
    
    nonisolated func cancel() {
        isCancelled = true
    }
}
