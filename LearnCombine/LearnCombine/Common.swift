import Foundation
import Combine

func asyncMain(_ block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        block()
    }
}

func log(_ text: String) {
    print(text)
}

private var shareCancellables = Set<AnyCancellable>()

private func add(_ cancel: AnyCancellable?, ifNeeded: Bool) {
    guard let cancel = cancel, ifNeeded else { return }
    log("shareAutoCancellables.insert(\(cancel.hashValue))")
    shareCancellables.insert(cancel)
    log("BagSize: \(shareCancellables.count)")
    
}

// return: success
private func remove(_ cancel: AnyCancellable?) -> Bool {
    guard let cancel = cancel else { return false }
    log("shareAutoCancellables.remove(\(cancel.hashValue))")
    shareCancellables.remove(cancel)
    log("BagSize: \(shareCancellables.count)")
    return true
}

extension Publisher {
    public func sinkAndDispose(
        receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
        receiveValue: @escaping ((Self.Output) -> Void)) {
        var cancellable: AnyCancellable?
        var removedFromBag = false
        cancellable = sink { (completion) in
            receiveCompletion(completion)
            removedFromBag = remove(cancellable)
        } receiveValue: { (value) in
            receiveValue(value)
        }
        add(cancellable, ifNeeded: !removedFromBag)
    }
    
    public func sinkAndDispose(receiveValue: @escaping ((Self.Output) -> Void)) {
        var cancellable: AnyCancellable?
        var removedFromBag = false
        cancellable = sink { (completion) in
            removedFromBag = remove(cancellable)
        } receiveValue: { (value) in
            removedFromBag = remove(cancellable)
            receiveValue(value)
        }
        add(cancellable, ifNeeded: !removedFromBag)
    }

}
