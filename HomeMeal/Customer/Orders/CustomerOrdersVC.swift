//
//  CustomerOrdersVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class CustomerOrdersVC: BaseVC {
    
    let dbRef = Database.database().reference()
    
    var timer: Timer?
    var orders = [Order]()
    var groupedOrders = [OrderStatus:[Order]]()
    var selectedOrderType: OrderStatus = .received
    let ordersTableCellId = "customerOrdersTableViewCellId"
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
        segmented.insertSegment(withTitle: OrderStatusText.prepared.text, at: 2, animated: true)
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
        observeCustomerOrders()
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
        setNavBarTitle("My Orders".getLocalizedString())
        let btnShowPastOrders = UIBarButtonItem(image: AppIcons.listWhiteIcon, style: .plain, target: self, action: #selector(showPastOrders))
        self.navigationItem.rightBarButtonItems = [btnShowPastOrders]
    }
    
    @objc func showPastOrders(){
        let customerPastOrdersVC = CustomerPastOrdersVC()
        self.navigationController?.pushViewController(customerPastOrdersVC, animated: true)
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
        ordersTable.register(CustomerOrdersTableViewCell.self, forCellReuseIdentifier: ordersTableCellId)
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
        case 2:
            self.selectedOrderType = .prepared
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
extension CustomerOrdersVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) as? CustomerOrdersTableViewCell{
            if let selectedOrder = currentCell.order {
                DispatchQueue.main.async {
                    let customerOrderDetailVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "CustomerOrderDetailsVC") as! CustomerOrderDetailsVC
                    customerOrderDetailVC.order = selectedOrder
                    self.present(customerOrderDetailVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectedOrderType {
        case .received:
            if let orders = groupedOrders[.received]{
                if orders.isEmpty {
                    return emptyOrdersTableCellHeight
                }else{
                    return ordersTableCellHeight
                }
            }else{
                return emptyOrdersTableCellHeight
            }
        case .preparing:
            if let orders = groupedOrders[.preparing]{
                if orders.isEmpty {
                    return emptyOrdersTableCellHeight
                }else{
                    return ordersTableCellHeight
                }
            }else{
                return emptyOrdersTableCellHeight
            }
        case .prepared:
            if let orders = groupedOrders[.prepared]{
                if orders.isEmpty {
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
            if let orders = groupedOrders[.received]{
                if orders.isEmpty {
                    return 1
                }else{
                    return orders.count
                }
            }else{
                return 1
            }
        case .preparing:
            if let orders = groupedOrders[.preparing]{
                if orders.isEmpty {
                    return 1
                }else{
                    return orders.count
                }
            }else{
                return 1
            }
        case .prepared:
            if let orders = groupedOrders[.prepared]{
                if orders.isEmpty {
                    return 1
                }else{
                    return orders.count
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
            if let orders = groupedOrders[.received]{
                if orders.isEmpty {
                    return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.ordersTableCellId, for: indexPath) as! CustomerOrdersTableViewCell
                    cell.order = orders[indexPath.row]
                    return cell
                }
            }else{
                return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
            }
        case .preparing:
            if let orders = groupedOrders[.preparing]{
                if orders.isEmpty {
                    return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.ordersTableCellId, for: indexPath) as! CustomerOrdersTableViewCell
                    cell.order = orders[indexPath.row]
                    return cell
                }
            }else{
                return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
            }
        case .prepared:
            if let orders = groupedOrders[.prepared]{
                if orders.isEmpty {
                    return getEmptyOrdersErrorCell(with: noOrdersErrorMessage)
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: self.ordersTableCellId, for: indexPath) as! CustomerOrdersTableViewCell
                    cell.order = orders[indexPath.row]
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
extension CustomerOrdersVC {
    private func observeCustomerOrders(){
        guard let uid = AppConstants.currentUserId else{
            return
        }
        let customerOrdersPath = "customerOrders/\(uid)"
        
        showActivityIndicatorView(isUserInteractionEnabled: false)
        
        // ORDER ADDED TO CUSTOMER ORDERS
        dbRef.child(customerOrdersPath).observe(.childAdded) { (snapshot) in
            let orderId = snapshot.key
            let orderStatus = OrderStatus(rawValue: (snapshot.value as! Int)) ?? OrderStatus.canceled
            switch orderStatus {
            case .received, .preparing, .prepared:
                self.getOrderBy(orderId: orderId)
                return
            default:
                return
            }
        }
        
        // ORDER UPDATED IN CUSTOMER ORDERS
        dbRef.child(customerOrdersPath).observe(.childChanged) { (snapshot) in
            let orderId = snapshot.key
            let orderStatus = OrderStatus(rawValue: (snapshot.value as! Int)) ?? OrderStatus.canceled
            switch orderStatus {
            case .received, .preparing, .prepared:
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
        if let index = orders.firstIndex(where: { (order) -> Bool in
            return order.orderDetails.orderId == updatedOrder.orderDetails.orderId
        }){
            orders[index] = updatedOrder
            attemptReloadOfTableView()
        }
    }
    
    private func getOrderBy(orderId: String){
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
