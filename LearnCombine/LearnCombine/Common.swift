import Foundation
import Combine

func log(_ text: String) {
    print(text)
}

private var shareCancellables = Set<AnyCancellable>()

private func add(_ cancel: AnyCancellable?) {
    guard let cancel = cancel else { return }
//    log("shareAutoCancellables.insert(\(cancel.hashValue))")
    shareCancellables.insert(cancel)
    
}

private func remove(_ cancel: AnyCancellable?) {
    guard let cancel = cancel else { return }
//    log("shareAutoCancellables.remove(\(cancel.hashValue))")
    shareCancellables.remove(cancel)
}

extension Publisher {
    public func sinkAndDispose(
        receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
        receiveValue: @escaping ((Self.Output) -> Void)) {
        
        var cancellable: AnyCancellable?
        cancellable = sink { (completion) in
            receiveCompletion(completion)
            remove(cancellable)
        } receiveValue: { (value) in
            receiveValue(value)
        }
        add(cancellable)
    }

}
