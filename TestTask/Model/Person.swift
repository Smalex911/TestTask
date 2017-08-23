//
//  Person.swift
//  TestTask
//
//  Created by Александр Смородов on 18.08.17.
//  Copyright © 2017 Александр. All rights reserved.
//

import UIKit
import Foundation

let urlString = "https://randomuser.me/api/?page=1&results=10&nat=us"

struct Person {
    var icon = UIImage()
    let iconM: String
    let iconL: String
    let name: String
    let surname: String
    let birthday: String
    let location: (street: String, city: String, state: String, postcode: Int)
    let phone: String
    let email: String
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(icon: UIImage, iconM: String, iconL: String, name: String,surname: String, birthday: String, location: Dictionary<String, String>, phone: String, email: String) {
        self.icon = icon
        self.iconM = iconM
        self.iconL = iconL
        self.name = name
        self.surname = surname
        self.birthday = birthday
        self.location = (
            location["street"]!,
            location["city"]!,
            location["state"]!,
            Int(location["postcode"]!)!)
        self.phone = phone
        self.email = email
    }
    
    init(json: [String: Any]) throws {
        // Extract icon
        guard let iconJSON = json["picture"] as? [String: String],
            let iconM = iconJSON["medium"],
            let iconL = iconJSON["large"]
            else {
                throw SerializationError.missing("picture")
        }
        
        func UppercaseFirstCharacter(text: String?) -> String? {
            if text != nil {
                return String(describing: text!.characters.first!).uppercased() + String(text!.characters.dropFirst())
            }
            return nil
        }
        
        // Extract name and surname
        guard let nameJSON = json["name"] as? [String: String],
            let name = UppercaseFirstCharacter(text: nameJSON["first"]),
            let surname = UppercaseFirstCharacter(text: nameJSON["last"])
            else {
                throw SerializationError.missing("name")
        }
        
        // Extract birthday
        guard let birthday = json["dob"] as? String else {
            throw SerializationError.missing("dob")
        }
        
        // Extract location
        guard let locationJSON = json["location"] as? [String: Any],
            let street = locationJSON["street"] as? String,
            let city = UppercaseFirstCharacter(text: locationJSON["city"] as? String),
            let state = UppercaseFirstCharacter(text: locationJSON["state"] as? String),
            let postcode = locationJSON["postcode"] as? Int
            else {
                throw SerializationError.missing("location")
        }
        
        // Extract phone
        guard let phone = json["phone"] as? String else {
            throw SerializationError.missing("phone")
        }
        
        // Extract email
        guard let email = json["email"] as? String else {
            throw SerializationError.missing("email")
        }
        
        // Initialize properties
        self.iconM = iconM
        self.iconL = iconL
        self.name = name
        self.surname = surname
        self.birthday = birthday
        self.location = (street, city, state, postcode)
        self.phone = phone
        self.email = email
    }
    
    static func persons(completion: @escaping (NSMutableArray) -> Void) {
        let marrStudentInfo = NSMutableArray()
        let searchURL = URL(string: urlString)
        
        URLSession.shared.dataTask(with:searchURL!) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    let results = (parsedData["results"] as! [[String:Any]])
                    
                    for item in results {
                        
                        var person = try Person(json: item)
                        
                        DispatchQueue.main.sync() {
                            if let data = NSData(contentsOf: URL(string: person.iconM)!) {
                                person.icon = UIImage(data: data as Data)!
                            }
                        }
                        marrStudentInfo.add(person)
                        if !ModelManager.getInstance().addUserData(userInfo: person) {
                            print("Не удалось записать данные в бд")
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            completion(marrStudentInfo)
            }.resume()
    }
}
