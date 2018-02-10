//
//  SignUpViewController.swift
//  Wegmans Planner
//
//  Created by Olufunmilola Babalola on 2/10/18.
//  Copyright © 2018 TFW. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBAction func skipBtn(_ sender: Any) {
        performSegue(withIdentifier: "setupSuccessful", sender: self)
    
    }
    
    @IBAction func signUp(_ sender: Any) {
        performSegue(withIdentifier: "setupSuccessful", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
