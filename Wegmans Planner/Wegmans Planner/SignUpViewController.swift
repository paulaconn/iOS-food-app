//
//  SignUpViewController.swift
//  Wegmans Planner
//
//  Created by Olufunmilola Babalola on 2/10/18.
//  Copyright © 2018 TFW. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var shoppersClubText: UITextField!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var store_count: UILabel!
    
    var stores : [String] = []
    var validForm = false
    
    var alertEmail = ""
    var alertPhone = 0
    
    @IBAction func emailSearch(_ sender: Any) {
        let alert = UIAlertController(title: "Get Shoppers Club Card Number by Email Search",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            // optionally configure the text field
            textField.keyboardType = .emailAddress
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned alert] (action) in
            if let textField = alert.textFields?.first as UITextField? {
                self.alertEmail = textField.text!
            }
            print("The email to search for is ",self.alertEmail)
            self.validateShoppersClubByEmail(myEmail: self.alertEmail)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func phoneSearch(_ sender: Any) {
        let alert = UIAlertController(title: "Get Shoppers Club Card Number by Phone Number Search",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            // optionally configure the text field
            textField.keyboardType = .phonePad
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned alert] (action) in
            if let textField = alert.textFields?.first as UITextField? {
                self.alertPhone = Int(textField.text!)!
                print(textField.text ?? "Please enter a phone number.")
            }
            print("The phone to search for is ",self.alertPhone)
            self.validateShoppersClubByPhone(myPhone: self.alertPhone)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func skipBtn(_ sender: Any) {
        performSegue(withIdentifier: "setupSuccessful", sender: self)
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        // check storage for saved sign up info
        let userDefaults = UserDefaults.init(suiteName: "WegmansPlanner")
        //print(userDefaults)
        
        // Setting Values
        userDefaults?.set(nameText.text!, forKey: "username")
        if (shoppersClubText.text?.isEmpty)!{
            userDefaults?.set(0, forKey: "shopperClub")
        }
        else{
            userDefaults?.set(shoppersClubText.text, forKey: "shopperClub")
        }
        userDefaults?.set(locationPicker,forKey: "defaultStore")
        userDefaults?.synchronize()
        performSegue(withIdentifier: "setupSuccessful", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseLocation()
        
        // check storage for saved sign up info
        let userDefaults = UserDefaults(suiteName: "WegmansPlanner")
        //print(userDefaults)
        
        // Getting Values
        let userName = userDefaults?.string(forKey:"username")
        let shopperClub = userDefaults?.double(forKey: "shopperClub")
        let userShop = userDefaults?.string(forKey: "defaultStore")
        userDefaults?.synchronize()
        
        if (userShop != nil) {
            performSegue(withIdentifier: "setupSuccessful", sender: self)
        }
        
        // Do any additional setup after loading the view.
        locationPicker.dataSource = self
        locationPicker.delegate = self
        locationPicker?.reloadAllComponents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let location = "New York"
    let city = "Rochester"
    
    func parseLocation(){
        let url = URL(string: "https://api.wegmans.io/location/location/stores")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("4982e31c064e40708e5984724133018a", forHTTPHeaderField: "Location-Subscription-Key")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if (error != nil){
                print(error)
                return
            }
            if let data = data{
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict_data = json as? [[String : Any]]{
                        //var close_store_arr = [[String : Any]]()
                        for store in dict_data{
                            if let store_location = store["Location"] as? [String: Any]{
                                if let store_state = store_location["State"] as? String {
                                    if store_state == self.location.uppercased(){
                                        //close_store_arr.append(store)
                                        self.stores.append(store["Name"] as! String)
                                        //print(store)
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.store_count.text = "\(self.stores.count) locations"
                        }
                        //print(close_store_arr)
//                        for shop in self.stores{
//                            print(shop["Name"]!)
//                        }
                    }
                    else {
                        print(json)
                        print("cast json to dictionary error")
                    }
                }
                catch {
                    print("no data")
                }
            }
        }
        task.resume()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return stores[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.stores.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func displayStoreInfo(){
        //locationPicker.dataSource = close_store_arr
        print(self.stores)
    }
    
    func validateShoppersClubByPhone(myPhone: Int){
        print(myPhone)
        let url = URL(string: "https://api.wegmans.io/loyalty/search/phone_numbers?phoneNumber=\(myPhone)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("4982e31c064e40708e5984724133018a", forHTTPHeaderField: "Loyalty-Subscription-Key")
        var shoppersCard = ""
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if (error != nil){
                print(error)
                return
            }
            if let data = data{
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict_data = json as? [String : Any]{
                        print(dict_data)
                        //shoppersCard = (dict_data["Links"] as? String)!
                    }
                    else {
                        print(json)
                        print("cast json to dictionary error")
                    }
                }
                catch {
                    print("no data")
                }
            }
            
        }
        task.resume()
        shoppersClubText.text = shoppersCard
    }
    
    
    func validateShoppersClubByEmail(myEmail:String){
        print(myEmail)
        let url = URL(string: "https://api.wegmans.io/loyalty/search/email_addresses?emailAddress=\(myEmail)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("4982e31c064e40708e5984724133018a", forHTTPHeaderField: "Loyalty-Subscription-Key")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if (error != nil){
                print(error)
                return
            }
            if let data = data{
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict_data = json as? [String : Any]{
                        print(dict_data)
                    }
                    else {
                        print(json)
                        print("cast json to dictionary error")
                    }
                }
                catch {
                    print("no data")
                }
            }
        }
        task.resume()
    }
}
