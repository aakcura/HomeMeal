//
//  CustomerMealListVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase
import Cosmos
import MapKit
import CoreLocation

class CustomerMealListVC: BaseVC {

    enum MealListSearchType: Int {
        case searchByChefName = 0
        case searchByMealName = 1
        case searchByPrice = 2
        case searchByRating = 3
    }
    
    var isLocationSortActive: Bool?{
        didSet{
            if self.isLocationSortActive! {
                checkAuthorizationStatusForUserLocation()
            }else{
                self.locationManager.stopUpdatingLocation()
                self.attemptReloadOfTableView()
                self.navigationItem.rightBarButtonItem?.tintColor = .white
            }
        }
    }
    var locationManager: CLLocationManager!

    var userLocation = CLLocation()
    
    
    let dbRef = Database.database().reference()
    
    var selectedSearchType: MealListSearchType = .searchByChefName
    
    var timer: Timer?
    var searchedMeals = [Meal]()
    var allMeals = [Meal]()
    var chefs = [String:Chef]()
    let mealListTableCellId = "mealListTableViewCellId"
    let noMealsErrorMessage = "No Meals Error Message".getLocalizedString()
    let mealsTableCellHeight: CGFloat = {
        return CGFloat.init(260.0)
    }()
    let emptyMealsTableCellHeight: CGFloat = {
        return CGFloat.init(100.0)
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let mealsTable : UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.white
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeNavBarBackButtonText()
        setupUIProperties()
        setupLocationManager()
        observeOrderableMealList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addNetworkStatusListener()
    }
    
    private func setupUIProperties(){
        view.backgroundColor = .white
        customizeNavBar()
        configureSearchController()
        setupTableView()
        addActivityIndicatorToView()
    }
    
    private func customizeNavBar(){
        setNavBarTitle("Meal List".getLocalizedString())
        let btnLocationFilter = UIBarButtonItem(image: AppIcons.locationArrowIcon, style: .plain, target: self, action: #selector(locationFilterTapped))
        self.navigationItem.rightBarButtonItem = btnLocationFilter
    }
    
    private func configureSearchController(){
        searchController.searchBar.barTintColor = AppColors.navBarBackgroundColor
        searchController.searchBar.tintColor = .white
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.scopeButtonTitles = ["Chef".getLocalizedString(), "Meal".getLocalizedString(), "Price".getLocalizedString(), "Rating".getLocalizedString()]
        definesPresentationContext = true
        mealsTable.tableHeaderView = searchController.searchBar
    }
    
    @objc private func locationFilterTapped(){
        let alert = UIAlertController(title: nil, message: "List of meals will be listed according to your location".getLocalizedString(), preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        
        if let isLocationSortActive = self.isLocationSortActive {
            if isLocationSortActive {
                let deactivateLocationSort = UIAlertAction(title: "Deactivate".getLocalizedString(), style: .default, handler: { (action) in
                    self.isLocationSortActive = false
                })
                alert.addAction(deactivateLocationSort)
            }else{
                let activateLocationSort = UIAlertAction(title: "Activate".getLocalizedString(), style: .default, handler: { (action) in
                    self.isLocationSortActive = true
                })
                alert.addAction(activateLocationSort)
            }
        }else{
            let activateLocationSort = UIAlertAction(title: "Activate".getLocalizedString(), style: .default, handler: { (action) in
                self.isLocationSortActive = true
            })
            alert.addAction(activateLocationSort)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func setupTableView(){
        self.view.addSubview(mealsTable)
        mealsTable.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, padding: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
        mealsTable.register(MealListTableViewCell.self, forCellReuseIdentifier: mealListTableCellId)
        mealsTable.separatorStyle = .none
        mealsTable.dataSource = self
        mealsTable.delegate = self
    }
}

// LOCATION MANAGER SECTION
extension CustomerMealListVC: CLLocationManagerDelegate{
    
    private func setupLocationManager(){
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if self.locationManager.delegate == nil {
            self.locationManager.delegate = self
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkAuthorizationStatusForUserLocation()
    }
    
    func checkAuthorizationStatusForUserLocation(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied,.restricted:
            self.handleLocationAccessDenied()
            break
        case .authorizedWhenInUse:
            self.handleLocationAccessGranted()
            break
        default:
            break
        }
    }
    

    func handleLocationAccessDenied(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Location Permission".getLocalizedString(), message: "No location permission".getLocalizedString(), preferredStyle: .alert)
            let closeButton = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
            let openSettingsButton = UIAlertAction(title: "Open Settings".getLocalizedString(), style: .default, handler: { (action) in
                UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            })
            alert.addAction(closeButton)
            alert.addAction(openSettingsButton)
            self.present(alert, animated: true, completion: nil)
        }
        self.isLocationSortActive = false
    }
    
    func handleLocationAccessGranted(){
        if self.isLocationSortActive == nil {
            self.isLocationSortActive = true
            return
        }
        locationManager.startUpdatingLocation()
        navigationItem.rightBarButtonItem?.tintColor = .blue
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let updatedUserLocation = locations[0]
        if !userLocation.coordinate.latitude.isEqual(to: updatedUserLocation.coordinate.latitude) && !userLocation.coordinate.longitude.isEqual(to: updatedUserLocation.coordinate.longitude){
            userLocation = updatedUserLocation
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus == .authorizedWhenInUse {
                sortMealsByUserLocation(userLocation)
            }
        }
    }
    
    private func sortMealsByUserLocation(_ userLocation: CLLocation){
        self.searchedMeals.sort { (meal2, meal1) -> Bool in
            if let meal2KitchenLocation = meal2.chef?.kitchenInformation.getKitchenLocation(), let meal1KitchenLocation = meal1.chef?.kitchenInformation.getKitchenLocation() {
                let distanceBetweenUserAndMeal2KitchenLocation = userLocation.distance(from: meal2KitchenLocation)
                let distanceBetweenUserAndMeal1KitchenLocation = userLocation.distance(from: meal1KitchenLocation)
                
                if distanceBetweenUserAndMeal2KitchenLocation < distanceBetweenUserAndMeal1KitchenLocation {
                    return true
                }else{
                    return false
                }
            }else{
                return false
            }
        }
        
        DispatchQueue.main.async {
            self.mealsTable.reloadData()
        }
    }
    
}

// SEARC BAR SECTION
extension CustomerMealListVC: UISearchResultsUpdating, UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchController.searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.selectedSearchType = MealListSearchType(rawValue: selectedScope) ?? MealListSearchType.searchByMealName
        var placeholderText = ""
        switch self.selectedSearchType {
        case .searchByPrice:
            placeholderText = "searchByPricePlaceholderText".getLocalizedString()
            break
        case .searchByRating:
            placeholderText = "searchByRatingPlaceholderText".getLocalizedString()
            break
        default:
            placeholderText = "Search".getLocalizedString()
            break
        }
        searchBar.placeholder = placeholderText
        filterSearchController(searchBar)
    }
    
    private func isMealsSortedByUserLocation() -> Bool{
        if let isLocationSortActive = self.isLocationSortActive {
            return isLocationSortActive
        }else{
            return false
        }
    }
    
    private func sortMealsByChefNameASC(){
        self.searchedMeals.sort(by: { (meal2, meal1) -> Bool in
            return meal2.chefName.trimmingCharacters(in: CharacterSet.whitespaces).localizedCaseInsensitiveCompare(meal1.chefName.trimmingCharacters(in: CharacterSet.whitespaces).localizedLowercase) == ComparisonResult.orderedAscending
        })
        DispatchQueue.main.async {
            self.mealsTable.reloadData()
        }
    }
    
    private func sortMealsByMealNameASC(){
        self.searchedMeals.sort(by: { (meal2, meal1) -> Bool in
            return meal2.mealName.trimmingCharacters(in: CharacterSet.whitespaces).localizedCaseInsensitiveCompare(meal1.mealName    .trimmingCharacters(in: CharacterSet.whitespaces).localizedLowercase) == ComparisonResult.orderedAscending
        })
        DispatchQueue.main.async {
            self.mealsTable.reloadData()
        }
    }
    
    private func sortMealsByPriceASC(){
        self.searchedMeals.sort { (meal2, meal1) -> Bool in
            return meal2.price < meal1.price
        }
        DispatchQueue.main.async {
            self.mealsTable.reloadData()
        }
    }
    
    private func sortMealsByRatingDESC(){
        self.searchedMeals.sort { (meal2, meal1) -> Bool in
            if let meal2Rating = meal2.chef?.rating, let meal1Rating = meal1.chef?.rating{
                return meal2Rating > meal1Rating
            }else{
                return false
            }
        }
        DispatchQueue.main.async {
            self.mealsTable.reloadData()
        }
    }
    
    func filterSearchController(_ searchBar: UISearchBar){
        let searchText = searchBar.text ?? ""
        switch self.selectedSearchType {
        case .searchByChefName:
            self.searchedMeals = allMeals.filter { meal in
                let isMatchingSearchText =    meal.chefName.localizedLowercase.contains(searchText.localizedLowercase) || searchText.localizedLowercase.count == 0
                return isMatchingSearchText
            }
            
            if !isMealsSortedByUserLocation() {
                sortMealsByChefNameASC()
                return
            }
            break
        case .searchByMealName:
            self.searchedMeals = allMeals.filter { meal in
                let isMatchingSearchText =    meal.mealName.localizedLowercase.contains(searchText.localizedLowercase) || searchText.localizedLowercase.count == 0
                return isMatchingSearchText
            }
            
            if !isMealsSortedByUserLocation() {
                sortMealsByMealNameASC()
                return
            }
            break
        case .searchByPrice:
            var priceText = searchText.replacingOccurrences(of: " ", with: "").split(separator: "-")
            if !priceText.isEmpty && priceText.count == 2, let firstPrice = Double(priceText[0]), let secondPrice = Double(priceText[1]){
                self.searchedMeals = allMeals.filter({ (meal) -> Bool in
                    let isMatchingSearchText = (firstPrice <= meal.price && meal.price <= secondPrice) || searchText.localizedLowercase.count == 0
                    return isMatchingSearchText
                })
                if !isMealsSortedByUserLocation() {
                    sortMealsByPriceASC()
                    return
                }
                break
            }
            
            let priceGreaterThanText = searchText.replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
            if let price = Double(priceGreaterThanText){
                self.searchedMeals = allMeals.filter({ (meal) -> Bool in
                    let isMatchingSearchText = meal.price > price || searchText.localizedLowercase.count == 0
                    return isMatchingSearchText
                })
                if !isMealsSortedByUserLocation() {
                    sortMealsByPriceASC()
                    return
                }
                break
            }
            
            let priceLessThanText = searchText.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: " ", with: "")
            if let price = Double(priceLessThanText){
                self.searchedMeals = allMeals.filter({ (meal) -> Bool in
                    let isMatchingSearchText = meal.price < price || searchText.localizedLowercase.count == 0
                    return isMatchingSearchText
                })
                if !isMealsSortedByUserLocation() {
                    sortMealsByPriceASC()
                    return
                }
                break
            }
            
            self.searchedMeals = allMeals
            if !isMealsSortedByUserLocation() {
                sortMealsByPriceASC()
                return
            }
            break
        case .searchByRating:
            var ratingText = searchText.replacingOccurrences(of: " ", with: "").split(separator: "-")
            if !ratingText.isEmpty && ratingText.count == 2, let firstRating = Double(ratingText[0]), let secondRating = Double(ratingText[1]){
                self.searchedMeals = allMeals.filter({ (meal) -> Bool in
                    let isMatchingSearchText = (firstRating <= (meal.chef?.rating)! && (meal.chef?.rating)! <= secondRating) || searchText.localizedLowercase.count == 0
                    return isMatchingSearchText
                })
                if !isMealsSortedByUserLocation() {
                    sortMealsByRatingDESC()
                    return
                }
                break
            }
            
            let ratingGreaterThanText = searchText.replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
            if let rating = Double(ratingGreaterThanText){
                self.searchedMeals = allMeals.filter({ (meal) -> Bool in
                    let isMatchingSearchText = (meal.chef?.rating)! > rating || searchText.localizedLowercase.count == 0
                    return isMatchingSearchText
                })
                if !isMealsSortedByUserLocation() {
                    sortMealsByRatingDESC()
                    return
                }
                break
            }
            
            let ratingLessThanText = searchText.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: " ", with: "")
            if let rating = Double(ratingLessThanText){
                self.searchedMeals = allMeals.filter({ (meal) -> Bool in
                    let isMatchingSearchText = (meal.chef?.rating)! < rating || searchText.localizedLowercase.count == 0
                    return isMatchingSearchText
                })
                if !isMealsSortedByUserLocation() {
                    sortMealsByRatingDESC()
                    return
                }
                break
            }
            
            self.searchedMeals = allMeals
            if !isMealsSortedByUserLocation() {
                sortMealsByRatingDESC()
                return
            }
            break
        }
        DispatchQueue.main.async {
            self.mealsTable.reloadData()
        }
    }
}

// TABLE VIEW
extension CustomerMealListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) as? MealListTableViewCell{
            if let selectedMeal = currentCell.meal {
                DispatchQueue.main.async {
                    let mealDetailVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "MealDetailVC") as! MealDetailVC
                    mealDetailVC.meal = selectedMeal
                    self.present(mealDetailVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchedMeals.isEmpty {
            return emptyMealsTableCellHeight
        }else{
            return mealsTableCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchedMeals.isEmpty {
            return 1
        }else{
            return searchedMeals.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchedMeals.isEmpty {
            return getEmptyOrdersErrorCell(with: noMealsErrorMessage)
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: self.mealListTableCellId, for: indexPath) as! MealListTableViewCell
            cell.meal = searchedMeals[indexPath.row]
            return cell
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
        self.sortMeals()
        DispatchQueue.main.async(execute: {
            self.mealsTable.reloadData()
            if self.activityIndicator.isAnimating{
                self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            }
        })
    }
    
    private func sortMeals(){
        self.searchedMeals = allMeals.sorted(by: { (meal2, meal1) -> Bool in
            return meal2.startTime < meal1.startTime
        })
    }
    
    private func getEmptyOrdersErrorCell(with message:String) -> UITableViewCell{
        let errorCell = UITableViewCell()
        errorCell.textLabel?.textAlignment = .center
        errorCell.textLabel?.numberOfLines = 0
        errorCell.textLabel?.adjustsFontSizeToFitWidth = true
        errorCell.textLabel?.text = message
        return errorCell
    }
}

// FIREBASE OPERATIONS
extension CustomerMealListVC {
    private func observeOrderableMealList(){
        let orderableMealsPath = "orderableMeals"
        dbRef.child(orderableMealsPath).observe(.childAdded) { (snapshot) in
            let mealId = snapshot.key
            self.getMealBy(mealId: mealId)
        }
        
        dbRef.child(orderableMealsPath).observe(.childRemoved) { (snapshot) in
            let mealId = snapshot.key
            self.removeMeal(mealId: mealId)
        }
    }
    
    private func removeMeal(mealId: String){
        if let index = allMeals.firstIndex(where: { (meal) -> Bool in
            return meal.mealId == mealId
        }){
            allMeals.remove(at: index)
            attemptReloadOfTableView()
        }
    }
    
    private func addNewMealToMeals(_ newMeal:Meal){
        allMeals.append(newMeal)
        if let chef = chefs[newMeal.chefId]{
            newMeal.chef = chef
        }else{
            getChefBy(chefId: newMeal.chefId)
        }
        attemptReloadOfTableView()
    }
    
    private func updateMealInMeals(_ updatedMeal:Meal, index: Int){
        allMeals[index] = updatedMeal
    }
    
    
    private func updateAllMealsOfChefWithUpdatedChefInfo(_ chef:Chef){
        for meal in allMeals{
            if meal.chefId == chef.userId{
                meal.chef = chef
            }
        }
        attemptReloadOfTableView()
    }
    
    private func getChefBy(chefId:String){
        dbRef.child("chefs/\(chefId)").observe(.value) { (snapshot) in
            if let chefDictionary = snapshot.value as? [String:AnyObject]{
                let chef = Chef(dictionary: chefDictionary)
                self.chefs[chefId] = chef
                self.updateAllMealsOfChefWithUpdatedChefInfo(chef)
            }
        }
    }
    
    private func getMealBy(mealId:String){
        dbRef.child("meals/\(mealId)").observeSingleEvent(of: .value) { (snapshot) in
            if let mealDictionary = snapshot.value as? [String:AnyObject]{
                let meal = Meal(dictionary: mealDictionary)
                if let index = self.allMeals.firstIndex(where: { (meal) -> Bool in
                    return meal.mealId == mealId
                }){
                    self.updateMealInMeals(meal, index: index)
                }else{
                    self.addNewMealToMeals(meal)
                }
            }
        }
    }
    
}
