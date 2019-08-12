
/* FİREBASE HANDLER EXAMPLE
 
import UIKit
import Firebase

class MenuVC: BaseVC {
    
    let dbRef = Database.database().reference()
    var firebaseObserverHandleDictionary = [String:UInt]()
    
    var mealsDictionary: [String:Meal] = [String:Meal]()
    var activeMeals: [String:Meal] = [String:Meal]()
    var passiveMeals: [String:Meal] = [String:Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
        observeChefMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listenChefMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addNetworkStatusListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for item in self.firebaseObserverHandleDictionary.keys {
            if let handler = self.firebaseObserverHandleDictionary[item]{
                self.dbRef.child(item).removeObserver(withHandle: handler)
            }
        }
    }
    
    private func setupUIProperties(){
        view.backgroundColor = .white
        customizeNavBar()
        addActivityIndicatorToView()
    }
    
    private func customizeNavBar(){
        setNavBarTitle("Menu".getLocalizedString())
        let btnGoPrepareMealScreen = UIBarButtonItem.init(image: AppIcons.plusWhiteIcon, style: .plain, target: self, action: #selector(goPrepareMealScreen))
        self.navigationItem.rightBarButtonItems = [btnGoPrepareMealScreen]
        //self.navigationItem.leftBarButtonItems = [myProfileBarButton]
        //let logoutButton = UIBarButtonItem.init(image: AppIcons.logoutIcon, style: .plain, target: self, action: #selector(logoutButtonClicked))
    }
    
    @objc func goPrepareMealScreen(){
        let mealPreparationVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "MealPreparationVC")
        self.navigationController?.pushViewController(mealPreparationVC, animated: true)
    }
    
    private func observeChefMenu(){
        guard let uid = AppConstants.currentUserId else{
            return
        }
        let chefMenuPath = "menu/\(uid)"
        
        showActivityIndicatorView(isUserInteractionEnabled: false)
        
        let newMealAddedChefMenuHandler = dbRef.child(chefMenuPath).observe(.childAdded) { (snapshot) in
            let mealId = snapshot.key
            //let mealStatus = MealStatus(rawValue: (snapshot.value as! Int)) ?? MealStatus.canNotBeOrdered
            self.getMealBy(mealId: mealId)
        }
        self.firebaseObserverHandleDictionary[chefMenuPath] = newMealAddedChefMenuHandler
        
        let mealUpdatedAtChefMenuHandler = dbRef.child(chefMenuPath).observe(.childChanged) { (snapshot) in
            let mealId = snapshot.key
            let mealStatus = MealStatus(rawValue: (snapshot.value as! Int)) ?? MealStatus.canNotBeOrdered
            print(mealId,mealStatus)
        }
        self.firebaseObserverHandleDictionary[chefMenuPath] = mealUpdatedAtChefMenuHandler
        
        let mealRemovedFromChefMenuHandler = dbRef.child(chefMenuPath).observe(.childRemoved) { (snapshot) in
            let mealId = snapshot.key
            let mealStatus = MealStatus(rawValue: (snapshot.value as! Int)) ?? MealStatus.canNotBeOrdered
            self.removeMeal(mealId: mealId, mealStatus: mealStatus)
        }
        self.firebaseObserverHandleDictionary[chefMenuPath] = mealRemovedFromChefMenuHandler
    }
    
    
    private func removeMeal(mealId: String, mealStatus: MealStatus){
        self.mealsDictionary.removeValue(forKey: mealId)
        switch mealStatus {
        case .canBeOrdered:
            self.activeMeals.removeValue(forKey: mealId)
            break
        case .canNotBeOrdered:
            self.passiveMeals.removeValue(forKey: mealId)
            break
        }
        
        // TODO Reload table view
    }
    
    private func addNewMealToMealsDictionary(_ newMeal:Meal){
        self.mealsDictionary[newMeal.mealId] = newMeal
        switch newMeal.mealStatus {
        case .canBeOrdered:
            self.activeMeals[newMeal.mealId] = newMeal
            break
        case .canNotBeOrdered:
            self.passiveMeals[newMeal.mealId] = newMeal
            break
        }
        // TODO Reload TABLE VİEW
    }
    
    private func updateMealInMealsDictionary(_ updatedMeal:Meal){
        let mealId = updatedMeal.mealId
        let mealOldStatus = self.mealsDictionary[mealId]!.mealStatus
        let mealNewStatus = updatedMeal.mealStatus
        
        if mealOldStatus == mealNewStatus {
            switch mealNewStatus {
            case .canBeOrdered:
                self.activeMeals[mealId] = updatedMeal
                break
            case .canNotBeOrdered:
                self.passiveMeals[mealId] = updatedMeal
                break
            }
        }else{
            switch mealOldStatus {
            case .canBeOrdered:
                self.activeMeals.removeValue(forKey: mealId)
                break
            case .canNotBeOrdered:
                self.passiveMeals.removeValue(forKey: mealId)
                break
            }
            
            switch mealNewStatus {
            case .canBeOrdered:
                self.activeMeals[mealId] = updatedMeal
                break
            case .canNotBeOrdered:
                self.passiveMeals[mealId] = updatedMeal
                break
            }
        }
        
        self.mealsDictionary[mealId] = updatedMeal
        
        // TODO Reload TABLE VIEW
    }
}

// FIREBASE OPERATIONS
extension MenuVC {
    func getMealBy(mealId: String){
        let mealPath = "meals/\(mealId)"
        let getMealHandler = dbRef.child(mealPath).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                if self.mealsDictionary.keys.contains(mealId){
                    let updatedMeal = Meal(dictionary: dictionary)
                    self.updateMealInMealsDictionary(updatedMeal)
                }else{
                    let newMeal = Meal(dictionary: dictionary)
                    self.addNewMealToMealsDictionary(newMeal)
                }
            }
        }
        self.firebaseObserverHandleDictionary[mealPath] = getMealHandler
    }
    
    func getMealBy(mealId: String, completion: @escaping (Meal?) -> Void){
        let mealPath = "meals/\(mealId)"
        let getMealHandler = dbRef.child(mealPath).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                if self.mealsDictionary.keys.contains(mealId){
                    let updatedMeal = Meal(dictionary: dictionary)
                    completion(updatedMeal)
                }else{
                    let newMeal = Meal(dictionary: dictionary)
                    completion(newMeal)
                }
            }else{
                completion(nil)
            }
        }
        self.firebaseObserverHandleDictionary[mealPath] = getMealHandler
    }
}
*/
