//
//  KitchenLocationPickerVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


protocol HandleMapSearch{
    func dropPinZoomIn(placemark:MKPlacemark)
}

class KitchenLocationPickerVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stackKitchenAddressDescription: UIStackView!
    @IBOutlet weak var lblKitchenAddressDescriptionStackTitle: UILabel!
    @IBOutlet weak var tvKitchenAddressDescription: UITextView!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnConfirmLocation: UIButton!
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark?
    var addressDescriptionText: String? = nil
    var kitchenInformation: KitchenInformation?
    
    var kitchenInformationDelegate: KitchenInformationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let kitchenInformation = kitchenInformation{
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: kitchenInformation.latitude, longitude: kitchenInformation.longitude))
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(placemark)
            selectedPin = placemark
            addressDescriptionText = kitchenInformation.addressDescription
            tvKitchenAddressDescription.textColor = UIColor.black
            tvKitchenAddressDescription.text = addressDescriptionText
        }
    }
    
    private func setupUIProperties(){
        mapView.delegate = self
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(recognizer)
        
        // BEGIN NAV SEARCH BAR SETTINGS
        let locationSearchTVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "LocationSearchTVC") as! LocationSearchTVC
        resultSearchController = UISearchController(searchResultsController: locationSearchTVC)
        resultSearchController?.searchResultsUpdater = locationSearchTVC
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Type address".getLocalizedString()
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTVC.mapView = mapView
        locationSearchTVC.handleMapSearchDelegate = self
        // END NAV SEARCH BAR SETTINGS

        //lblKitchenAddressDescriptionStackTitle.text = "Kitchen Address Description".getLocalizedString()
        let kitchenAddressDescriptionStackTitle = NSMutableAttributedString.init(string: "Kitchen Address Description".getLocalizedString())
        kitchenAddressDescriptionStackTitle.underline()
        lblKitchenAddressDescriptionStackTitle.attributedText = kitchenAddressDescriptionStackTitle
        tvKitchenAddressDescription.text = "KitchenAddressDescriptionPlaceHolder".getLocalizedString()
        tvKitchenAddressDescription.textColor = AppColors.textViewPlaceHolderColor
        tvKitchenAddressDescription.delegate = self
        tvKitchenAddressDescription.translatesAutoresizingMaskIntoConstraints = false
        tvKitchenAddressDescription.setCornerRadius(radiusValue: 5.0)
        btnConfirmLocation.translatesAutoresizingMaskIntoConstraints = false
        btnConfirmLocation.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnConfirmLocation.setTitle("Confirm Location".getLocalizedString(), for: .normal)
    }
    
    @IBAction func confirmLocationTapped(_ sender: Any) {
        if let selectedPin = selectedPin, let addressDescription = addressDescriptionText, addressDescription != "" , addressDescription.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            let dictionary = ["latitude":selectedPin.coordinate.latitude, "longitude":selectedPin.coordinate.longitude, "addressDescription":addressDescription] as [String:AnyObject]
            let chefKitchenInformation = KitchenInformation(dictionary: dictionary)
            self.kitchenInformationDelegate?.confirmKitchenInformation(chefKitchenInformation)
            self.navigationController?.popViewController(animated: true)
        }else{
            var errorText = ""
            if selectedPin == nil && addressDescriptionText == nil {
                errorText = "Kitchen location and address description cannot be left blank.".getLocalizedString()
            }else if selectedPin == nil {
                errorText = "Kitchen location must be selected.".getLocalizedString()
            }else{
                errorText = "Address description cannot be left blank.".getLocalizedString()
            }
            
            AlertService.showAlert(in: self, message: errorText, title: "Error".getLocalizedString(), style: .alert)
        }
    }
    
    @IBAction func infoTapped(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            AlertService.showAlert(in: self, message: "KitchenLocationPickerInformationText".getLocalizedString(), title: "Information".getLocalizedString(), style: .alert)
        }
    }
}

// MAP VIEW DELEGATE
extension KitchenLocationPickerVC: MKMapViewDelegate {
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let choosenCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            chosenLatitude = choosenCoordinates.latitude
            chosenLongitude = choosenCoordinates.longitude
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: chosenLatitude, longitude: chosenLongitude))
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(placemark)
            selectedPin = placemark
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView: MKPinAnnotationView
        if let reusablePinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView{
            pinView = reusablePinView
        } else{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView.pinTintColor = UIColor.orange
        pinView.canShowCallout = true
        pinView.animatesDrop = true
        pinView.isDraggable = true
        
        return pinView
    }
}

// TEXT VIEW DELEGATE
extension KitchenLocationPickerVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.tvKitchenAddressDescription.textColor == AppColors.textViewPlaceHolderColor {
            self.tvKitchenAddressDescription.text = nil
            self.tvKitchenAddressDescription.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.tvKitchenAddressDescription.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            self.tvKitchenAddressDescription.text = "KitchenAddressDescriptionPlaceHolder".getLocalizedString()
            self.tvKitchenAddressDescription.textColor = AppColors.textViewPlaceHolderColor
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else{ return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= AppConstants.kitchenAddressDescriptionCharacterCountLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == tvKitchenAddressDescription.tag {
            let addressDescription = tvKitchenAddressDescription.text == "KitchenAddressDescriptionPlaceHolder".getLocalizedString() ? nil : tvKitchenAddressDescription.text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\n", with: " ")
            if let addressDescription = addressDescription{
                tvKitchenAddressDescription.backgroundColor = nil
                addressDescriptionText = addressDescription
            }else{
                tvKitchenAddressDescription.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                addressDescriptionText = nil
            }
        }
    }
}

// SEARCH BAR DELEGATE
extension KitchenLocationPickerVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            // search text nil
            return
        }
        
    }
}

// HANDLE MAP SEARCH
extension KitchenLocationPickerVC: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
