import UIKit
import Combine

typealias Cancels = Set<AnyCancellable>

class DetailViewController: UIViewController {
    let presenter = DetailViewPresenter()
    var cancels = Cancels()
    
    override func viewDidLoad() {

    }
    
    @IBAction func tapped(_ sender: Any) {
        presenter.tappedButton()
    }
}
let commonError = NSError(domain: "", code: 0, userInfo: nil)

var number = 0
class DetailViewPresenter {
    func tappedButton() {
        let aSquare = squareInFuture(5)
        let bSquare = squareInFuture(7)
        let add = addInFuture(a: aSquare, b: bSquare)
        
        add.sinkAndDispose { (completion) in
            switch completion {
            case .finished: print("finished")
            case .failure(let error): print("failure \(error)")
            }
        } receiveValue: { (value) in
            print("result in Future: \(value)")
        }
    }
    
    func squareInFuture(_ a: Int) -> Future<Int, Error> {
        .init { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if a % 5 == 0 {
                    promise(.failure(commonError))
                }
                print("squareInFuture promise(.success(\(a * a)))")
                promise(.success(a * a))
            }
        }
    }
    
    func addInFuture(a: Future<Int, Error>, b: Future<Int, Error>) -> Future<Int, Error> {
        .init { promise in
            a.zip(b).sinkAndDispose { (a, b) in
                print("addInFuture promise(.success(\(a + b)))")
                promise(.success(a + b))
            }
        }
    }
}
