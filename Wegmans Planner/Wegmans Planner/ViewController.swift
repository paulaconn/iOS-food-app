//
//  ViewController.swift
//  Wegmans Planner
//
//  Created by Olufunmilola Babalola on 2/10/18.
//  Copyright © 2018 TFW. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //parseLocation()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // PG: Removed for API Call Test
    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //    // Dispose of any resources that can be recreated.
    //}
    
    let location = "New York"
    let city = "Rochester"
    @IBOutlet var store_count: UILabel!
    
    func parseLocation(){
        let url = URL(string: "https://api.wegmans.io/location/location/stores")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("4982e31c064e40708e5984724133018a", forHTTPHeaderField: "Location-Subscription-Key")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            //print(error)
            //print(data)
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
                            self.store_count.text = "\(close_store_arr.count)"
                        }
                        print(close_store_arr)
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
    
    @IBAction func button_pressed(_ sender: Any) {
        parseLocation()
    }
    

}

