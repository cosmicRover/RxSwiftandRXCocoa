import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  let europeanChocolates = Observable.just(Chocolate.ofEurope)//it now observes for any chocolate of type europe
  //just means the underlying type wont change but I still need to be able to observe this property
  private let disposeBag = DisposeBag()
}

//MARK: View Lifecycle
extension ChocolatesOfTheWorldViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    
//    tableView.dataSource = self
//    tableView.delegate = self
    
    setupCartObserver()//start observinng on viewDidLoad
    setupCellConfiguration()//rx tableView
    setupCellTapHandling()//rx tableView tap handling
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //updateCartButton()
  }
}

//MARK: - Rx Setup
private extension ChocolatesOfTheWorldViewController {
  
  func setupCartObserver(){
    //lisetn to shopping cart's onNext data events. Dispose the connection at the end with disposeBag
    ShoppingCart.sharedCart.chocolates.asObservable().subscribe(onNext:{
      chocolates in self.cartButton.title = "\(chocolates.count) \u{1f36b}"
      }).disposed(by: disposeBag)
  }
  
  //setup tableView with rx
  func setupCellConfiguration(){
    europeanChocolates.bind(to: tableView
      .rx.items(cellIdentifier: ChocolateCell.Identifier, cellType: ChocolateCell.self)){
        row, chocolate, cell in
      
      //configureWithChocolate() is a cell's func from within cell's class
      cell.configureWithChocolate(chocolate: chocolate)}.disposed(by: disposeBag)
  }
  
  func setupCellTapHandling(){
    //subscribe to onTap callbacks on tableView
    tableView.rx.modelSelected(Chocolate.self)
      .subscribe(onNext:{
        chocolate in
        let newValue = ShoppingCart.sharedCart.chocolates.value + [chocolate] //add the new chocolate with old
        ShoppingCart.sharedCart.chocolates.accept(newValue) //push it back to the sinngleton as the updated value
      }).disposed(by: disposeBag)
  }
  
}

//MARK: - Imperative methods
private extension ChocolatesOfTheWorldViewController {
//  func updateCartButton() {
//    cartButton.title = "\(ShoppingCart.sharedCart.chocolates.value.count) \u{1f36b}"
//  }
}

// MARK: - Table view data source
//extension ChocolatesOfTheWorldViewController: UITableViewDataSource {
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1
//  }
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return europeanChocolates.count
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChocolateCell.Identifier, for: indexPath) as? ChocolateCell else {
//      //Something went wrong with the identifier.
//      return UITableViewCell()
//    }
//
//    let chocolate = europeanChocolates[indexPath.row]
//    cell.configureWithChocolate(chocolate: chocolate)
//
//    return cell
//  }
//}
//
//// MARK: - Table view delegate
//extension ChocolatesOfTheWorldViewController: UITableViewDelegate {
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    tableView.deselectRow(at: indexPath, animated: true)
//
//    let chocolate = europeanChocolates[indexPath.row]
//
//    //appending a new chocolate to the singleton and handing it off to the singleton again as accept(newValue)
//    let newValue = ShoppingCart.sharedCart.chocolates.value + [chocolate]
//    ShoppingCart.sharedCart.chocolates.accept(newValue)
//    //updateCartButton()
//  }
//}

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  enum SegueIdentifier: String {
    case goToCart
  }
}
