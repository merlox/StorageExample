//
//  Storage.swift
//  StorageExample
//
//  Created by Merunas Grincalaitis on 25/03/2020.
//  Copyright © 2020 Merunas Grincalaitis. All rights reserved.
//
//

import Foundation

// MARK: This MyData is the serialized data that we'll save
// 1. Inherit NSObject and NSCoding
class MyData: NSObject, NSCoding {
    enum Keys: String {
        case one = "shownInitialPermissionsMessage"
        case two = "notificationsAccepted"
    }
    // 2. Setup variables
    var shownInitialPermissionsMessage: Bool
    var notificationsAccepted: Bool

    // 3. Setup init constructor
    init(_ shownInitialPermissionsMessage: Bool, _ notificationsAccepted: Bool) {
        self.shownInitialPermissionsMessage = shownInitialPermissionsMessage
        self.notificationsAccepted = notificationsAccepted
    }

    // 4. Setup the encoder to parse data
    func encode(with coder: NSCoder) {
        coder.encode(shownInitialPermissionsMessage, forKey: Keys.one.rawValue)
        coder.encode(notificationsAccepted, forKey: Keys.two.rawValue)
    }

    required convenience init?(coder: NSCoder) {
        let shownInitialPermissionsMessage = coder.decodeBool(forKey: "shownInitialPermissionsMessage")
        let notificationsAccepted = coder.decodeBool(forKey: "notificationsAccepted")
        self.init(shownInitialPermissionsMessage, notificationsAccepted)
    }
}

// MARK: Methods to save and get data stored in the iOS database
// Utilities to save and retrieve data
struct Utilities {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // 1
    func getData() -> MyData? {
        let fileName = "myUserData"
        let fullPath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: fullPath)
            if let loadedStrings = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? MyData {
                return loadedStrings
            }
        } catch {
            print("Couldn't read the stored data")
        }
        return nil
    }
    
    // ObjectToSave is the data we want to save
    func setData(objectToSave: MyData) -> Bool {
        let fileName = "myUserData"
        let fullPath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: objectToSave, requiringSecureCoding: false)
            try data.write(to: fullPath)
            return true
        } catch {
            print("Error saving file")
        }
        return false
    }
}

// MARK: The example() function shows you how to use this entire process, you get a result
// which may be empty if things are not saved
struct Storage {
    static func getInitialData() -> MyData? {
        let myUtilities = Utilities()
        return myUtilities.getData()
    }
    
    // The function that executes everything
    func example() {
        let myUtilities = Utilities()
        let result = myUtilities.getData() // 1
        
        if result != nil {
            print("A", result?.shownInitialPermissionsMessage ?? "abc")
            print("B", result?.notificationsAccepted ?? "abc")
        } else {
            let myData = MyData(false, false)
            myData.shownInitialPermissionsMessage = true
            myData.notificationsAccepted = true
            if myUtilities.setData(objectToSave: myData) {
                print("Data saved successfully")
            } else {
                print("Data NOT saved")
            }
        }
    }
}
