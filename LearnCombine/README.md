#  Combine Notes

```
Just
Future
Deferred
Empty
Sequence
Fail
Record
Share
Multicast
ObservableObject
@Published
```

## Publishers (Observables) Phát tín hiệu

## Subscribers (Observers) Nhận tín hiệu





### @Published vs ObservableObject

@Published: propertyWrapper auto generate Publisher cho Object

```swift
typealias Cancels = Set<AnyCancellable>
class DetailViewController: UIViewController {
    @IBOutlet weak var testLabel: UILabel!
    let presenter = DetailViewPresenter()
    var cancels = Cancels()
    
    override func viewDidLoad() {
        // Push value khi object `state` change bất kỳ field nào
        presenter.state.objectWillChange.sink {
            print("objectWillChange.sink: \(self.presenter.state.text)")
        }.store(in: &cancels)
        
        // Ngay lập tức push value hiện tại của object ngay khi vùa được đăng ký sink
        presenter.state.$text.sink { value in
            print("$text.sink: \(value)")
        }.store(in: &cancels)
    }
    
    @IBAction func tapped(_ sender: Any) {
        print("\n------ TAPPED -------")
        presenter.tappedButton()
    }
}

class DetailViewPresenter {
    @Published var state = DetailViewState()
    
    var count = 0
    func tappedButton() {
        count += 1
        state.text = "\(count)"
    }
}

class DetailViewState: ObservableObject {
    @Published var text = "Previous Value"
}

/*
$text.sink: Previous Value

------ TAPPED -------
objectWillChange.sink: Previous Value
$text.sink: 1

------ TAPPED -------
objectWillChange.sink: 1
$text.sink: 2
*/
```



### Filter & Map - SÀN LỌC & CHUYỂN HÓA

```swift
typealias Cancels = Set<AnyCancellable>
class DetailViewController: UIViewController {
    @IBOutlet weak var testLabel: UILabel!
    let presenter = DetailViewPresenter()
    var cancels = Cancels()
    
    override func viewDidLoad() {
        presenter.state.$number
            .filter {
                let accepted = $0 % 3 == 0
                let message = accepted ? "Accept" : "Reject"
                print("filter: \($0) --> \(message)")
                return accepted
            }
            .map { currentValue -> String in
                let newValue = "#\(currentValue)"
                print("map: current{\(currentValue)} -> new{\(newValue)}")
                return newValue
            }
            .sink { value in
                print("$text.sink: \(value)")
            }.store(in: &cancels)
    }
    
    @IBAction func tapped(_ sender: Any) {
        print("\n------ TAPPED -------")
        presenter.tappedButton()
    }
}

class DetailViewPresenter {
    @Published var state = DetailViewState()
    
    var index = 0
    var constNumbers = [4, 6, 2, 9, 0, 5, 8, 2, 10, 22, 65]
    func tappedButton() {
        index += 1
        index %= constNumbers.count
        state.number = constNumbers[index]
    }
}

class DetailViewState: ObservableObject {
    @Published var number = -95
}

/*
filter: -95 --> Reject

------ TAPPED -------
filter: 6 --> Accept
map: current{6} -> new{#6}
$text.sink: #6

------ TAPPED -------
filter: 2 --> Reject

------ TAPPED -------
filter: 9 --> Accept
map: current{9} -> new{#9}
$text.sink: #9

------ TAPPED -------
filter: 0 --> Accept
map: current{0} -> new{#0}
$text.sink: #0
*/
```



### Future - TƯƠNG LAI

Là 1 Publisher chỉ fire 1 `value` duy nhất hoặc fire `failure(error)`. Promise là method fire 

Tạo 1 future

```swift
    let future1 = Future<Int, Never> { promise in
        promise(.success(10)) // Fire value after processing
        // Future NeverError thì không thể fire .failure được
    }
    
    let future2 = Future<Int, Error> { promise in
        promise(.success(10)) // Fire value after processing
        promise(.failure(commonError)) // Fire error in case failure
    }
```



```swift
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
                print("squareInFuture promise(.success(\(a * a)))")
                promise(.success(a * a))
            }
        }
    }
    
    func addInFuture(a: Future<Int, Error>, b: Future<Int, Error>) -> Future<Int, Error> {
        .init { promise in
            a.zip(b).sinkAndDispose { (completion) in
                switch completion {
                case .finished: break
                case .failure(let error): promise(.failure(error))
                }
            } receiveValue: { (a, b) in
                print("addInFuture promise(.success(\(a + b)))")
                promise(.success(a + b))
            }
        }
    }
}

/*
squareInFuture promise(.success(25))
squareInFuture promise(.success(49))
addInFuture promise(.success(74))
result in Future: 74
finished
*/
```

