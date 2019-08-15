//
//  ChefOrdersVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//


import UIKit
import Firebase

class ChefOrdersVC: BaseVC {
    
    let dbRef = Database.database().reference()
    
    var timer: Timer?
    var orders = [Order]()
    var groupedOrders = [OrderStatus:[Order]]()
    var selectedOrderType: OrderStatus = .received
    let ordersTableCellId = "chefOrdersTableViewCellId"
    let noOrdersErrorMessage = "No Orders Error Message".getLocalizedString()
    let ordersTableCellHeight: CGFloat = {
        return CGFloat.init(200.0)
    }()
    let emptyOrdersTableCellHeight: CGFloat = {
        return CGFloat.init(50.0)
    }()
    
    
    let segmentedControl : UISegmentedControl = {
        let segmented = UISegmentedControl()
        segmented.insertSegment(withTitle: OrderStatusText.received.text, at: 0, animated: true)
        segmented.insertSegment(withTitle: OrderStatusText.preparing.text, at: 1, animated: true)
        segmented.selectedSegmentIndex = 0
        segmented.tintColor = AppColors.navBarBackgroundColor
        segmented.backgroundColor = UIColor.white
        let titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        segmented.setTitleTextAttributes(titleTextAttributes, for: .selected)
        return segmented
    }()
    
    let ordersTable : UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.white
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeNavBarBackButtonText()
        setupUIProperties()
        observeChefOrders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addNetworkStatusListener()
    }
    
    private func setupUIProperties(){
        view.backgroundColor = .white
        customizeNavBar()
        setupSegmentedControl()
        setupTableView()
        addActivityIndicatorToView()
    }
    
    private func customizeNavBar(){
        setNavBarTitle("Incoming Orders".getLocalizedString())
        let btnShowPastOrders = UIBarButtonItem(image: AppIcons.listWhiteIcon, style: .plain, target: self, action: #selector(showPastOrders))
        self.navigationItem.rightBarButtonItems = [btnShowPastOrders]
    }
    
    @objc func showPastOrders(){
        let chefPastOrdersVC = ChefPastOrdersVC()
        self.navigationController?.pushViewController(chefPastOrdersVC, animated: true)
        //self.present(chefPastOrdersVC, animated: true, completion: nil)
    }
    
    private func setupSegmentedControl(){
        self.view.addSubview(segmentedControl)
        segmentedControl.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, bottom: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 30))
        segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupTableView(){
        self.view.addSubview(ordersTable)
        ordersTable.anchor(top: self.segmentedControl.bottomAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, padding: UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10))
        ordersTable.register(ChefOrdersTableViewCell.self, forCellReuseIdentifier: ordersTableCellId)
        ordersTable.separatorStyle = .none
        ordersTable.dataSource = self
        ordersTable.delegate = self
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.selectedOrderType = .received
            break
        case 1:
            self.selectedOrderType = .preparing
            break
        default:
            break
        }
        DispatchQueue.main.async { [weak self] in
            self?.ordersTable.reloadData()
        }
    }
}

// TABLE VIEW
extension ChefOrdersVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) as? ChefOrdersTableViewCell{
            if let selectedOrder = currentCell.order {
                DispatchQueue.main.async {
                    let chefOrderDetailVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "ChefOrderDetailsVC") as! ChefOrderDetailsVC
                    chefOrderDetailVC.order = selectedOrder
                    self.present(chefOrderDetailVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectedOrderType {
        case .received:
            if let receivedOrders = groupedOrders[.received]{
                if receivedOrders.isEmpty {
                    return emptyOrdersTableCellHeight
                }else{
                    return ordersTableCellHeight
                }
            }else{
                return emptyOrdersTableCellHeight
            }
        case .preparing:
            if let prepairingOrders = groupedOrders[.preparing]{
                if prepairingOrders.isEmpty {
                    return emptyOrdersTableCellHeight
                }else{
                    return ordersTableCellHeight
                }
            }else{
                return emptyOrdersTableCellHeight
            }
        default:
            return emptyOrdersTableCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedOrderType {
        case .received:
            if let receivedOrders = groupedOrders[.received]{
                if receivedOrders.isEmpty {
                    return 1
                }else{
                    return receivedOrders.count
                }
            }else{
                return 1
            }
        case .preparing:
            if let prepairingOrders = groupedOrders[.preparing]{
                if prepairingOrders.isEmpty {
                    return 1
                }else{
                    return prepairingOrders.count
                }
            }else{
                return 1
            }
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedOrderType {
        case .received:
            if let receivedOrders = groupedOrders[.received]{
                if receivedOrders.isEmpty {
                    return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.ordersTableCellId, for: indexPath) as! ChefOrdersTableViewCell
                    cell.order = receivedOrders[indexPath.row]
                    return cell
                }
            }else{
                return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
            }
        case .preparing:
            if let prepairingOrders = groupedOrders[.preparing]{
                if prepairingOrders.isEmpty {
                    return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.ordersTableCellId, for: indexPath) as! ChefOrdersTableViewCell
                    cell.order = prepairingOrders[indexPath.row]
                    return cell
                }
            }else{
                return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
            }
        default:
            return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
        }
    }
    
    public func attemptReloadOfTableView() {
        if !activityIndicator.isAnimating{
            showActivityIndicatorView(isUserInteractionEnabled: false)
        }
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        self.groupAndOrderOrders()
        DispatchQueue.main.async(execute: {
            self.ordersTable.reloadData()
            if self.activityIndicator.isAnimating{
                self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            }
        })
    }
    
    private func groupAndOrderOrders(){
        self.groupedOrders.removeAll()
        self.groupedOrders = Dictionary(grouping: orders) { (order) -> OrderStatus in
            return order.orderDetails.orderStatus
        }
        groupedOrders.keys.forEach { (key) in
            groupedOrders[key]?.sort(by: { (order2, order1) -> Bool in
                return order2.orderDetails.orderTime > order1.orderDetails.orderTime
            })
        }
    }
    
    private func getEmptyOrdersErrorCell(with message:String) -> UITableViewCell{
        let errorCell = UITableViewCell()
        errorCell.textLabel?.textAlignment = .center
        errorCell.textLabel?.text = message
        return errorCell
    }
}

// FIREBASE OPERATIONS
extension ChefOrdersVC {
    private func observeChefOrders(){
        guard let uid = AppConstants.currentUserId else{
            return
        }
        let chefOrdersPath = "chefIncomingOrders/\(uid)"
        
        // ORDER ADDED TO CHEF INCOMING ORDERS
        dbRef.child(chefOrdersPath).observe(.childAdded) { (snapshot) in
            let orderId = snapshot.key
            let orderStatus = OrderStatus(rawValue: (snapshot.value as! Int)) ?? OrderStatus.rejected
            switch orderStatus {
            case .received, .preparing:
                self.getOrderBy(orderId: orderId)
                return
            default:
                return
            }
        }
        
        // ORDER UPDATED IN CHEF INCOMING ORDERS
        dbRef.child(chefOrdersPath).observe(.childChanged) { (snapshot) in
            let orderId = snapshot.key
            let orderStatus = OrderStatus(rawValue: (snapshot.value as! Int)) ?? OrderStatus.rejected
            switch orderStatus {
            case .received, .preparing:
                self.getOrderBy(orderId: orderId)
                return
            default:
                return
            }
        }
    }
    
    private func removeOrder(orderId: String, orderStatus: OrderStatus){
        if let index = orders.firstIndex(where: { (order) -> Bool in
            return order.orderDetails.orderId == orderId
        }){
            orders.remove(at: index)
            attemptReloadOfTableView()
        }
    }
    
    private func addNewOrderToOrders(_ newOrder:Order){
        orders.append(newOrder)
        attemptReloadOfTableView()
    }
    
    private func updateOrderInOrders(_ updatedOrder:Order, index: Int){
        orders[index] = updatedOrder
        attemptReloadOfTableView()
    }
    
    private func getOrderBy(orderId: String){
        showActivityIndicatorView(isUserInteractionEnabled: false)
        dbRef.child("orders/\(orderId)").observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                if let index = self.orders.firstIndex(where: { (order) -> Bool in
                    return order.orderDetails.orderId == orderId
                }){
                    let updatedOrder = Order(dictionary: dictionary)
                    self.updateOrderInOrders(updatedOrder, index: index)
                }else{
                    let newOrder = Order(dictionary: dictionary)
                    self.addNewOrderToOrders(newOrder)
                }
            }
        }
    }
    
    // NOT IN USE
    private func getOrderBy(orderId: String, completion: @escaping (Order?) -> Void){
        let orderPath = "orders/\(orderId)"
        dbRef.child(orderPath).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let order = Order(dictionary: dictionary)
                completion(order)
            }else{
                completion(nil)
            }
        }
    }
}
