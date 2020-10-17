//
//  ViewController.swift
//  LearnCombine
//
//  Created by Trung on 10/16/20.
//

import UIKit
import Combine

typealias CancellableBag = [Cancellable]

func << (left: inout CancellableBag, right: Cancellable) {
    left.append(right)
}

extension CancellableBag {
    func cancel() {
        forEach { $0.cancel() }
    }
}

class DetailViewController: UIViewController {
    @IBOutlet weak var testLabel: UILabel!
    let presenter = Presenter()
    var bag = CancellableBag()
    
    override func viewDidLoad() {
        bag << presenter.state.objectWillChange.sink {
            print("presenter.state.objectWillChange.sink = \(self.presenter.state.text)")
        }
        
        bag << presenter.state.$text.sink { value in
            print("presenter.state.$text.sink = \(value)")
        }
        
    }
    
    @IBAction func tapped(_ sender: Any) {
        presenter.tappedButton()
    }
}

class Presenter {
    @Published var state = ViewState()
    
    var count = 0
    func tappedButton() {
        count += 1
        state.text = "\(count)"
    }
}

class ViewState: ObservableObject {
    @Published var text = "INIT"
}
