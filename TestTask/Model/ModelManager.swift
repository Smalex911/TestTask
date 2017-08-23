//
//  ModelManager.swift
//  DataBaseDemo
//
//  Created by Krupa-iMac on 05/08/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: FMDatabase? = nil

    class func getInstance() -> ModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: Util.getPath(fileName: "Users.sqlite"))
        }
        return sharedInstance
    }
    
    func addTable() -> Bool {
        sharedInstance.database!.open()
        let isCreated = sharedInstance.database!.executeUpdate("CREATE TABLE IF NOT EXISTS users_info(icon TEXT, iconM TEXT, iconL TEXT, name TEXT, surname TEXT, birthday TEXT, street TEXT, city TEXT, state TEXT, postcode INTEGER, phone TEXT, email TEXT)", withArgumentsIn: [])
        sharedInstance.database!.close()
        return isCreated
    }
    
    func addUserData(userInfo: Person) -> Bool {
        let imageData:NSData = UIImagePNGRepresentation(userInfo.icon)! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO users_info (icon, iconM, iconL, name, surname, birthday, street, city, state, postcode, phone, email) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [strBase64, userInfo.iconM, userInfo.iconL, userInfo.name, userInfo.surname, userInfo.birthday, userInfo.location.street, userInfo.location.city, userInfo.location.state, userInfo.location.postcode, userInfo.phone, userInfo.email])
        sharedInstance.database!.close()
        return isInserted
    }
   
//    func updateStudentData(userInfo: Person) -> Bool {
//        sharedInstance.database!.open()
//        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE users_info SET Name=?, Surname=? WHERE Id=?", withArgumentsIn: [userInfo.name, userInfo.surname, userInfo.Id])
//        sharedInstance.database!.close()
//        return isUpdated
//    }
    
    func deleteUsersData() -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM users_info", withArgumentsIn: [])
        sharedInstance.database!.close()
        return isDeleted
    }

    func getAllUsersData() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM users_info", withArgumentsIn: [])
        let marrStudentInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let location = Dictionary(dictionaryLiteral:
                        ("street", resultSet.string(forColumn: "street")),
                        ("city", resultSet.string(forColumn: "city")),
                        ("state", resultSet.string(forColumn: "state")),
                        ("postcode", resultSet.string(forColumn: "postcode")))
                
                let dataDecoded = Data(base64Encoded: resultSet.string(forColumn: "icon")!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
                
                let userInfo = Person(
                    icon: UIImage(data: dataDecoded)!,
                    iconM: resultSet.string(forColumn: "iconM")!,
                    iconL: resultSet.string(forColumn: "iconL")!,
                    name: resultSet.string(forColumn: "name")!,
                    surname: resultSet.string(forColumn: "surname")!,
                    birthday: resultSet.string(forColumn: "birthday")!,
                    location: location as! Dictionary<String, String>,
                    phone: resultSet.string(forColumn: "phone")!,
                    email: resultSet.string(forColumn: "email")!)
                marrStudentInfo.add(userInfo)
            }
        }
        sharedInstance.database!.close()
        return marrStudentInfo
    }
}
