//
//  UploadDataView.swift
//  MD3
//
//  Created by Students on 12/06/2020.
//  Copyright © 2020 KristapsNaglis. All rights reserved.
//

import UIKit
import Firebase

class UploadDataView: UIViewController {
    
    var ref: DatabaseReference!

    @IBOutlet var name: UITextField!
    @IBOutlet var decr: UITextField!
    @IBOutlet var lat: UITextField!
    @IBOutlet var lon: UITextField!
    @IBOutlet var submit: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ref = Database.database().reference()
    }
    
    @IBAction func ontouch(_ sender: Any) {
        let latDouble = Double(lat.text!)!
        let lonDouble = Double(lon.text!)!
        addData(latDouble, lonDouble)
    }
    
    func addData(_ lat: Double, _ lon: Double){
        ref.child("locations").child(name.text!).setValue([
            "name": name.text!,
            "description": decr.text!,
            "lat": lat,
            "lon": lon
        ])
    }

}
