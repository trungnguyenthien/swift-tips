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
    var bag = Set<AnyCancellable>()
    
    var defferedPubliser = Deferred {
        return Just(number)
    }.eraseToAnyPublisher()
    
    var justPubliser = Just(number)
    
    func tappedButton() {
        number = 2
        justPubliser.sink { (value) in
            print("SINK = \(number)")
        }.store(in: &bag)
    }
    
   
}
