//
//  ViewController.swift
//  Wegmans Planner
//
//  Created by Olufunmilola Babalola on 2/10/18.
//  Copyright © 2018 TFW. All rights reserved.
//

import UIKit

struct selected_product {
    var sku : String?
    var price : Double?
    var name : String?
    var allergies : String?
    var quantity : Int?
    var img_url : String?
    var location : String?
    var type : String?
    var warnings : String?
    
    init(sku : String? = nil,
         price : Double? = nil,
         name : String? = nil,
         allergies : String? = nil,
         quantity : Int? = nil,
         img_url : String? = nil,
         location : String? = nil,
         type : String? = nil,
         warnings : String? = nil) {
        self.sku = sku
        self.price = price
        self.name = name
        self.allergies = allergies
        self.quantity = quantity
        self.img_url = img_url
        self.location = location
        self.type = type
        self.warnings = warnings
    }
}

var prod = selected_product() ///STOPPED HERE

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar then do not filter the results
        if searchController.searchBar.text! == "" {
            filteredProductTableList = productTableList
        } else {
            // Filter the results
            filteredProductTableList = productTableList.filter { ($0.name?.lowercased().contains(searchController.searchBar.text!.lowercased()))! }
        }
        
        self.productTable.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productTableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = self.productTableList[indexPath.row].name
        cell.detailTextLabel?.text = self.productTableList[indexPath.row].price as! String?
        
        return cell
    }
    
    
    @IBOutlet weak var nyLocations: UINavigationItem!
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet var food_image: UIImageView!
    
    var productTableList = [selected_product]()
    var filteredProductTableList = [selected_product]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let location = "New York"
    let city = "Rochester"
    let price = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredProductTableList = productTableList
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        productTable.tableHeaderView = searchController.searchBar
        
        self.productTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Determine mySearch based on user input
        parseProducts(mySearch : "cereal")
        parsePrices()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Parse products from API (JSON)
    func parseProducts(mySearch : String){
        let url = URL(string: "https://api.wegmans.io/product/products/search?criteria=\(mySearch)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("4982e31c064e40708e5984724133018a", forHTTPHeaderField: "Product-Subscription-Key")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if (error != nil){
                print(error)
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict_data = json as? [String : Any]{
                        if let result_arr = dict_data["results"] as? [[String : Any]]{
                            var product_dict = [String: String]()
                            for product in result_arr {
                                if let product_name = product["description"] as? String, let product_sku = product["sku"] as? String{
                                    product_dict[product_name] = product_sku
                                }
                            }
                            
                            self.parseAllProductInformation(mySku: product_dict.values.first!)
                            
                            //These are related suggestions that the person searched for provide as buttons
                            print(product_dict)
                            //Save the description to the object
                        }
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
    }//end of parseProducts()
    
    // Obtain all Product Information (JSON)
    func parseAllProductInformation(mySku: String){
        let mySku = mySku
        let url = URL(string: "https://api.wegmans.io/product/products/\(mySku)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("4982e31c064e40708e5984724133018a", forHTTPHeaderField: "Product-Subscription-Key")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if (error != nil){
                print(error)
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict_data = json as? [String : Any]{
                        var prod = selected_product()
                        prod.sku = mySku
                        if let product_type = dict_data["ProductType"] as? String{
                            prod.type = product_type
                        }
                        if let product_warnings = dict_data["Warnings"] as? String{
                            prod.warnings = product_warnings
                        }
                        if let image_dict = dict_data["TradeIdentifierConfigurations"] as? [[String : Any]], let trade_arr = image_dict.first?["TradeIdentifiers"] as? [[String : Any]], let image_arr = trade_arr.first?["Images"] as? [[String : Any]], let image_url = image_arr.first?["Url"] as? String {
                            prod.img_url = "https://www.wegmans.com\(image_url)"
                            self.downloadFoodImg(url: prod.img_url!)
                        }
                        
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
    }//end of parseAllProductInformation()
    
    // Download image
    func downloadFoodImg(url:String){
        let task = URLSession.shared.dataTask(with: URL(string : url)!){
            (data, response, error) in
            if let data = data, error == nil, let img = UIImage(data : data){
                DispatchQueue.main.async {
                    self.food_image.image = img
                }
            }
        }
        task.resume()
    }//end of downloadFoodImg()
    
    // Reads location information from Wegmans API
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
                        var close_store_arr = [[String : Any]]()
                        for store in dict_data{
                            if let store_location = store["Location"] as? [String: Any]{
                                if let store_state = store_location["State"] as? String {
                                    if store_state == self.location.uppercased(){
                                        close_store_arr.append(store)
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
//                            self.store_count.text = "\(close_store_arr.count)"
                             self.nyLocations.title = "\(close_store_arr.count) stores in NY"
                        }
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
    }//end of parseLocation()
    
    //Button for loading store counts in parseLocation()
    @IBAction func button_pressed(_ sender: Any) {
        parseLocation()
    }

    // Parses the Prices data from the Wegmans API
    func parsePrices(){
        let url = URL(string: "https://api.wegmans.io/price/cart/total")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("4982e31c064e40708e5984724133018a", forHTTPHeaderField: "Price-Subscription-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var body = [String: Any]()
        var product: [String : Int] = ["Sku" : 701819, "Quantity" : 1]
        body["LineItems"] = [product]
        body["StoreNumber"] = 25
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Prints the request to be sent to API
        print(body)
        
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
                        if let total = dict_data["Total"] as? Double{
                            print(total)
                        }
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
    }//end of parsePrices()
    
}// end of view controller

