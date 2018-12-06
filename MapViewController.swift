//
//  MapViewController.swift
//  Amped Recovery App
//
//  Created by Gregg Weaver on 3/22/18.
//  Copyright © 2018 Amped. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase


class MapViewController: UIViewController, MKMapViewDelegate,  CLLocationManagerDelegate {
    
    var ref: DatabaseReference!
    @IBOutlet weak var facDetailTitle: UILabel!
    @IBOutlet weak var facilityImage: UIImageView!
    @IBOutlet weak var facilityAttOne: UILabel!
    @IBOutlet weak var facilityAttTwo: UILabel!
    @IBOutlet weak var facilityAttThree: UILabel!
    @IBOutlet weak var facilityAttFour: UILabel!
    @IBOutlet weak var useFacilityButton: UIButton!
    @IBOutlet weak var facilityOfferLabel: UILabel!
    var locManager: CLLocationManager = CLLocationManager()
    @IBOutlet weak var facilityLocations: MKMapView!
    
    let ann = MKPointAnnotation()
    var titleOutput = ""
    var timeSelected = ""
    var name: String?
    var location: CLLocationCoordinate2D?

    class Facility: NSObject, MKAnnotation {
        let title: String?
        let locationName: String
        let facilityType: String
        let attributeOne: String
        let attributeTwo: String
        let attributeThree: String
        let attributeFour: String
        let Image: UIImage
        let coordinate: CLLocationCoordinate2D
        
        init(title: String, locationName: String, facilityType: String, attributeOne: String, attributeTwo: String, attributeThree: String, attributeFour: String, image: UIImage, coordinate: CLLocationCoordinate2D) {
            self.title = title
            self.locationName = locationName
            self.facilityType = facilityType
            self.attributeOne = attributeOne
            self.attributeTwo = attributeTwo
            self.attributeThree = attributeThree
            self.attributeFour = attributeFour
            self.Image = image
            self.coordinate = coordinate
            super.init()
        }
        
    }
    
    var facilityArray: [Facility] = []
    
    let cryoWaveManBeachCA = Facility(title: "CryoWave",
                                      locationName: "CryoWave Manhattan Beach",
                                      facilityType: "Cryotherapy",
                                      attributeOne: "Whole Body Cyrotherapy",
                                      attributeTwo: "Localized Cryotherapy",
                                      attributeThree: "Normatec", attributeFour: "",
                                      image: #imageLiteral(resourceName: "CryoWaveMB"),
                                      coordinate: CLLocationCoordinate2D(latitude: 33.892765, longitude: -118.39643699999999))
    
    let beachCitiesCryo = Facility(title: "Beach Cities Cryo",
                                      locationName: "Cryo Torrance",
                                      facilityType: "Cryotherapy",
                                      attributeOne: "Whole Body Cyrotherapy",
                                      attributeTwo: "Infared Sauna",
                                      attributeThree: "Normatec", attributeFour: "Massage",
                                      image: #imageLiteral(resourceName: "BCC"),
                                      coordinate: CLLocationCoordinate2D(latitude: 33.8049565, longitude: -118.3487755))
    
    let floatLab = Facility(title: "Float Lab",
                                   locationName: "Venice",
                                   facilityType: "Floatation",
                                   attributeOne: "Float Tank",
                                   attributeTwo: "Vibration Therapy",
                                   attributeThree: "", attributeFour: "",
                                   image: #imageLiteral(resourceName: "floatLab"),
                                   coordinate: CLLocationCoordinate2D(latitude: 33.991099, longitude: -118.477097))
    
    let beachCitiesOtho = Facility(title: "Beach Cities Orthopedics",
                                   locationName: "Manhattan Beach",
                                   facilityType: "PT",
                                   attributeOne: "Massage",
                                   attributeTwo: "Graston",
                                   attributeThree: "", attributeFour: "",
                                   image: #imageLiteral(resourceName: "BCO"),
                                   coordinate: CLLocationCoordinate2D(latitude: 33.8759718, longitude: -118.3956055))
    
    let AMPSMR = Facility(title: "Amp Sports Medicine & Recovery",
    locationName: "Califonia",
    facilityType: "PT",
    attributeOne: "Therapist",
    attributeTwo: "Graston",
    attributeThree: "Normatec", attributeFour: "DMS",
    image: #imageLiteral(resourceName: "AMPSMR"),
    coordinate: CLLocationCoordinate2D(latitude: 33.6424442, longitude: -117.5739344))
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let findFacility = view.annotation?.title
        {
            showFacilityDetails(facilityTitle: findFacility!)
        }
    }
    
    func showFacilityDetails(facilityTitle: String){
        
        let a = facilityArray.index(where: { $0.title == facilityTitle })
        titleOutput = facilityArray[a!].title!
        let imageOutput = facilityArray[a!].Image
        let attOne = facilityArray[a!].attributeOne
        let attTwo = facilityArray[a!].attributeTwo
        let attThree = facilityArray[a!].attributeThree
        let attFour = facilityArray[a!].attributeFour
        facilityImage.image = imageOutput
        facDetailTitle.text = titleOutput
        facilityAttOne.text = attOne
        facilityAttTwo.text = attTwo
        facilityAttThree.text = attThree
        facilityAttFour.text = attFour
        
        useFacilityButton.isHidden = false
        facilityOfferLabel.isHidden = false
        
    }
    @IBAction func useFacilityButtonAction(_ sender: Any) {
    }
    
    // Function to pull information from database
    func showFacility(facilityName: String, completionHandler:@escaping (CLLocationCoordinate2D)-> Void) {
        
        ref.child("facilities").child(facilityName).observeSingleEvent(of: .value, with: { (snapshot) in

            let long = snapshot.value(forKey: "long") as? Double
            let lat = snapshot.value(forKey: "lat") as? Double
            let location = CLLocationCoordinate2DMake(lat!, long!)
            
            completionHandler(location)
        })
    }
    
    func facilityName(completionHandler:@escaping (String)-> Void) {
        
        ref.child("facilities").child("AMPSMR").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let name = snapshot.value(forKey: "name") as? String
            
            completionHandler(name!)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        
        ref = Database.database().reference()
        
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locManager.startUpdatingLocation()
            
        }
        

        let lat = locManager.location?.coordinate.latitude
        let long = locManager.location?.coordinate.longitude
        print(lat)
        
        if lat == nil {
            let initialLocation = CLLocationCoordinate2DMake(38.68591858, -99.05480122)
            let regionRadius: CLLocationDistance = 4000000
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation, regionRadius, regionRadius)
            facilityLocations.setRegion(coordinateRegion, animated: true)
        } else {
        let initialLocation = CLLocationCoordinate2DMake(lat!, long!)
        let regionRadius: CLLocationDistance = 12000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation, regionRadius, regionRadius)
        facilityLocations.setRegion(coordinateRegion, animated: true)
        }
        facilityLocations.showsUserLocation = true
        
    
        
        facilityArray.append(cryoWaveManBeachCA)
        facilityArray.append(beachCitiesCryo)
        facilityArray.append(beachCitiesOtho)
        facilityArray.append(floatLab)
        facilityArray.append(AMPSMR)
        
        
        facilityLocations.addAnnotation(cryoWaveManBeachCA)
        facilityLocations.addAnnotation(beachCitiesCryo)
        facilityLocations.addAnnotation(beachCitiesOtho)
        facilityLocations.addAnnotation(floatLab)
        facilityLocations.addAnnotation(AMPSMR)
        
        
        self.useFacilityButton.layer.borderWidth = 2
        self.useFacilityButton.layer.borderColor = UIColor.cyan.cgColor
        
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if let FacilitySliders = segue.destination as? FacilitySliders {FacilitySliders.facility = titleOutput;
            
            FacilitySliders.timeSelected = timeSelected;

}*/
}
}

