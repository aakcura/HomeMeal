//
//  MenuVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class ChefMenuVC: BaseVC {

    let dbRef = Database.database().reference()
    
    var timer: Timer?
    var meals = [Meal]()
    var groupedMeals = [MealStatus:[Meal]]()
    var selectedMenuType: MenuType = .active
    let menuTableCellId = "menuTableViewCellId"
    let noActiveMealsErrorMessage = "NoActiveMeals".getLocalizedString()
    let noPassiveMealsErrorMessage = "NoPassiveMeals".getLocalizedString()
    let menuTableCellHeight: CGFloat = {
       return CGFloat.init(222.0)
    }()
    let emptyMenuTableCellHeight: CGFloat = {
       return CGFloat.init(50.0)
    }()

    
    let segmentedControl : UISegmentedControl = {
        let segmented = UISegmentedControl()
        segmented.insertSegment(withTitle: "Orderable".getLocalizedString(), at: 0, animated: true)
        segmented.insertSegment(withTitle: "Not Orderable".getLocalizedString(), at: 1, animated: true)
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

    let menuTable : UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.white
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
        observeChefMenu()
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
        setNavBarTitle("Menu".getLocalizedString())
        let btnGoPrepareMealScreen = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goPrepareMealScreen))
        //UIBarButtonItem.init(image: AppIcons.plusWhiteIcon, style: .plain, target: self, action: #selector(goPrepareMealScreen))
        self.navigationItem.rightBarButtonItems = [btnGoPrepareMealScreen]
        //self.navigationItem.leftBarButtonItems = [myProfileBarButton]
        //let logoutButton = UIBarButtonItem.init(image: AppIcons.logoutIcon, style: .plain, target: self, action: #selector(logoutButtonClicked))
    }
    
    private func setupSegmentedControl(){
        self.view.addSubview(segmentedControl)
        segmentedControl.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, bottom: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 30))
        segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupTableView(){
        self.view.addSubview(menuTable)
        menuTable.anchor(top: self.segmentedControl.bottomAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, padding: UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10))
        menuTable.register(MenuTableViewCell.self, forCellReuseIdentifier: menuTableCellId)
        menuTable.separatorStyle = .none
        menuTable.dataSource = self
        menuTable.delegate = self
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.selectedMenuType = .active
            break
        case 1:
            self.selectedMenuType = .passive
            break
        default:
            break
        }
        DispatchQueue.main.async { [weak self] in
            self?.menuTable.reloadData()
        }
    }
    
    @objc func goPrepareMealScreen(){
        let mealPreparationVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "MealPreparationVC") as! MealPreparationVC
        //self.navigationController?.pushViewController(mealPreparationVC, animated: true)
        self.present(mealPreparationVC, animated: true, completion: nil)
    }
}

// TABLE VIEW
extension ChefMenuVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) as? MenuTableViewCell{
            if let selectedMeal = currentCell.meal {
                DispatchQueue.main.async {
                    let mealPreparationVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "MealPreparationVC") as! MealPreparationVC
                    mealPreparationVC.meal = selectedMeal
                    //self.navigationController?.pushViewController(mealPreparationVC, animated: true)
                    self.present(mealPreparationVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectedMenuType {
        case .active:
            if let activeMeals = groupedMeals[.canBeOrdered]{
                if activeMeals.isEmpty {
                    return emptyMenuTableCellHeight
                }else{
                    return menuTableCellHeight
                }
            }else{
                return emptyMenuTableCellHeight
            }
        case .passive:
            if let passiveMeals = groupedMeals[.canNotBeOrdered]{
                if passiveMeals.isEmpty {
                    return emptyMenuTableCellHeight
                }else{
                    return menuTableCellHeight
                }
            }else{
                return emptyMenuTableCellHeight
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedMenuType {
        case .active:
            if let activeMeals = groupedMeals[.canBeOrdered]{
                if activeMeals.isEmpty {
                    return 1
                }else{
                    return activeMeals.count
                }
            }else{
                return 1
            }
        case .passive:
            if let passiveMeals = groupedMeals[.canNotBeOrdered]{
                if passiveMeals.isEmpty {
                    return 1
                }else{
                    return passiveMeals.count
                }
            }else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedMenuType {
        case .active:
            if let activeMeals = groupedMeals[.canBeOrdered]{
                if activeMeals.isEmpty {
                    return getEmptyMenuErrorCell(with: noActiveMealsErrorMessage)
                }else{
                    let menuCell = tableView.dequeueReusableCell(withIdentifier: self.menuTableCellId, for: indexPath) as! MenuTableViewCell
                    menuCell.meal = activeMeals[indexPath.row]
                    return menuCell
                }
            }else{
                return getEmptyMenuErrorCell(with: noActiveMealsErrorMessage)
            }
        case .passive:
            if let passiveMeals = groupedMeals[.canNotBeOrdered]{
                if passiveMeals.isEmpty {
                    return getEmptyMenuErrorCell(with: noPassiveMealsErrorMessage)
                }else{
                    let menuCell = tableView.dequeueReusableCell(withIdentifier: self.menuTableCellId, for: indexPath) as! MenuTableViewCell
                    menuCell.meal = passiveMeals[indexPath.row]
                    return menuCell
                }
            }else{
                return getEmptyMenuErrorCell(with: noPassiveMealsErrorMessage)
            }
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
        self.groupAndOrderMeals()
        DispatchQueue.main.async(execute: {
            self.menuTable.reloadData()
            if self.activityIndicator.isAnimating{
                self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            }
        })
    }
    
    private func groupAndOrderMeals(){
        self.groupedMeals.removeAll()
        self.groupedMeals = Dictionary(grouping: meals) { (meal) -> MealStatus in
            return meal.mealStatus
        }
        groupedMeals.keys.forEach { (key) in
            groupedMeals[key]?.sort(by: { (meal2, meal1) -> Bool in
                return meal2.startTime > meal1.startTime
            })
        }
    }
    
    private func getEmptyMenuErrorCell(with message:String) -> UITableViewCell{
        let activeMenuEmptyCell = UITableViewCell()
        activeMenuEmptyCell.textLabel?.textAlignment = .center
        activeMenuEmptyCell.textLabel?.text = message
        return activeMenuEmptyCell
    }
}

// FIREBASE OPERATIONS
extension ChefMenuVC {
    private func observeChefMenu(){
        guard let uid = AppConstants.currentUserId else{
            return
        }
        let chefMenuPath = "menu/\(uid)"
        
        // MEAL ADDED TO CHEF MENU
        dbRef.child(chefMenuPath).observe(.childAdded) { (snapshot) in
            let mealId = snapshot.key
            self.getMealBy(mealId: mealId)
        }
        
        // MEAL UPDATED IN CHEF MENU
        /* dbRef.child(chefMenuPath).observe(.childChanged) { (snapshot) in
         let mealId = snapshot.key
         let mealStatus = MealStatus(rawValue: (snapshot.value as! Int)) ?? MealStatus.canNotBeOrdered
         print(mealId,mealStatus)
         } */
        
        // MEAL REMOVED FROM CHEF MENU
        dbRef.child(chefMenuPath).observe(.childRemoved) { (snapshot) in
            let mealId = snapshot.key
            let mealStatus = MealStatus(rawValue: (snapshot.value as! Int)) ?? MealStatus.canNotBeOrdered
            self.removeMeal(mealId: mealId, mealStatus: mealStatus)
        }
    }
    
    private func removeMeal(mealId: String, mealStatus: MealStatus){
        if let index = meals.firstIndex(where: { (meal) -> Bool in
            return meal.mealId == mealId
        }){
            meals.remove(at: index)
            attemptReloadOfTableView()
        }
    }
    
    private func addNewMealToMeals(_ newMeal:Meal){
        meals.append(newMeal)
        attemptReloadOfTableView()
    }
    
    private func updateMealInMeals(_ updatedMeal:Meal, index: Int){
        if let index = meals.firstIndex(where: { (meal) -> Bool in
            return meal.mealId == updatedMeal.mealId
        }){
            meals[index] = updatedMeal
            attemptReloadOfTableView()
        }
    }
    
    private func getMealBy(mealId: String){
        // GET MEAL FROM MEALS
        showActivityIndicatorView(isUserInteractionEnabled: false)
        dbRef.child("meals/\(mealId)").observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                if let index = self.meals.firstIndex(where: { (meal) -> Bool in
                    return meal.mealId == mealId
                }){
                    let updatedMeal = Meal(dictionary: dictionary)
                    self.updateMealInMeals(updatedMeal, index: index)
                }else{
                    let newMeal = Meal(dictionary: dictionary)
                    self.addNewMealToMeals(newMeal)
                }
            }
        }
    }
    
    // NOT IN USE
    private func getMealBy(mealId: String, completion: @escaping (Meal?) -> Void){
        let mealPath = "meals/\(mealId)"
        dbRef.child(mealPath).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let meal = Meal(dictionary: dictionary)
                completion(meal)
            }else{
                completion(nil)
            }
        }
    }
}
