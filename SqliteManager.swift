//
//  SqliteManager.swift
//  BaplsID
//
//  Created by nteam on 12/09/19.
//  Copyright © 2019 Hardik's Mac Mini. All rights reserved.
//

import UIKit
import SQLite3

class SqliteManager: NSObject {
    
    //MARK:- SHARED INSTANCE OF SQLITE MANAGER CLASS
    
    static let shared = SqliteManager()
    
    //MARK:- GET DATABASE PATH
    
    func databasePath() -> NSString{
        let path:Array = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let directory:String = path[0]
        let DBpath=(directory as NSString).appendingPathComponent("\(kDBName)")
        if (FileManager.default.fileExists(atPath: DBpath)){
            return DBpath as NSString
        }
        return DBpath as NSString
    }
    
    //MARK:- DML OPERATION FUNCTION
    
    func DMLExecuteQuery(_ str:String) -> Bool{
        var result:Bool = false
        let DBpath:String = self.databasePath() as String
        var db: OpaquePointer? = nil
        var stmt:OpaquePointer? = nil
        let strExec = str.cString(using: String.Encoding.utf8)
        if (sqlite3_open(DBpath, &db)==SQLITE_OK){
            if (sqlite3_prepare_v2(db, strExec! , -1, &stmt, nil) == SQLITE_OK){
                if (sqlite3_step(stmt) == SQLITE_DONE){
                    result=true
                }
            }
            sqlite3_finalize(stmt)
        }
        sqlite3_close(db)
        return result
    }
    
    //MARK:- CREATE DATABASE FUNCTION
    
    func createDatabaseifNeeded() {
        let arr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = arr[0]
        let finalPath = path.appending("/\(kDBName)")
        print(finalPath)
        let flm = FileManager()
        if !flm.fileExists(atPath: finalPath) {
            guard let localPath = Bundle.main.path(forResource: kAppName, ofType: "sqlite") else { return }
            
            do{
                try flm.copyItem(atPath: localPath, toPath: finalPath)
            }catch {
            }
        }
    }
    
    //MARK:- GET DATA FUNCTION
    
    func SelectQuery(_ str:String) -> [[String:String]]{
        var result:[[String:String]]=[]
        let DBpath:String=self.databasePath() as String
        var db: OpaquePointer? = nil
        var stmt:OpaquePointer? = nil
        let strExec = str.cString(using: String.Encoding.utf8)
        if ( sqlite3_open(DBpath,&db) == SQLITE_OK){
            if (sqlite3_prepare_v2(db, strExec! , -1, &stmt, nil) == SQLITE_OK){
                while (sqlite3_step(stmt) == SQLITE_ROW){
                    var icount:Int32 = sqlite3_column_count(stmt)
                    var dict : [String:String] = [:]
                    while icount > 0{
                        if let strV = sqlite3_column_text(stmt, icount){
                            let rValue:String = String(cString: strV)
                            if rValue.count > 0{
                                let strF = sqlite3_column_name(stmt, icount)
                                let rFiled:String = String(cString: strF!)
                                dict[rFiled] = rValue
                            }
                        }
                        icount -= 1
                    }
                    result.insert(dict, at: result.count)
                }
                sqlite3_finalize(stmt)
            }
            sqlite3_close(db)
        }
        return result
    }
    
    //MARK:- INSERT BULK DATA
    
    func bulkInsert(passScannedData: [[String: String]]) {
        
        let DBpath:String =  self.databasePath() as String
        var stmt:OpaquePointer? = nil
        var db: OpaquePointer? = nil
        
        if sqlite3_open(DBpath, &db) == SQLITE_OK {
            sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
        }else{
            return
        }
        let buffer : String = "INSERT INTO \(kTableName) (\(ScannedDataPrefix.age),\(ScannedDataPrefix.city),\(ScannedDataPrefix.dateOfExpiry),\(ScannedDataPrefix.dateOfIssue),\(ScannedDataPrefix.DOB),\(ScannedDataPrefix.documentNumber),\(ScannedDataPrefix.driverRestriction),\(ScannedDataPrefix.endorsement),\(ScannedDataPrefix.familyName),\(ScannedDataPrefix.firstName),\(ScannedDataPrefix.postalCode),\(ScannedDataPrefix.sex),\(ScannedDataPrefix.state),\(ScannedDataPrefix.street),\(ScannedDataPrefix.vehicleClass),\(ScannedDataPrefix.currentDateTime),\(ScannedDataPrefix.height),\(ScannedDataPrefix.weight)) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
        sqlite3_prepare_v2(db, buffer,Int32(strlen(buffer)), &stmt, nil)
        for dict in passScannedData {
            sqlite3_bind_text(stmt, 1, strdup(dict[ScannedDataPrefix.age]), -1, nil)
            sqlite3_bind_text(stmt, 2, strdup(dict[ScannedDataPrefix.city]), -1, nil)
            sqlite3_bind_text(stmt, 3, strdup(dict[ScannedDataPrefix.dateOfExpiry]), -1, nil)
            sqlite3_bind_text(stmt, 4, strdup(dict[ScannedDataPrefix.dateOfIssue]), -1, nil)
            sqlite3_bind_text(stmt, 5, strdup(dict[ScannedDataPrefix.DOB]), -1, nil)
            sqlite3_bind_text(stmt, 6, strdup(dict[ScannedDataPrefix.documentNumber]), -1, nil)
            sqlite3_bind_text(stmt, 7, strdup(dict[ScannedDataPrefix.driverRestriction]), -1, nil)
            sqlite3_bind_text(stmt, 8, strdup(dict[ScannedDataPrefix.endorsement]), -1, nil)
            sqlite3_bind_text(stmt, 9, strdup(dict[ScannedDataPrefix.familyName]), -1, nil)
            sqlite3_bind_text(stmt, 10, strdup(dict[ScannedDataPrefix.firstName]), -1, nil)
            sqlite3_bind_text(stmt, 11, strdup(dict[ScannedDataPrefix.postalCode]), -1, nil)
            sqlite3_bind_text(stmt, 12, strdup(dict[ScannedDataPrefix.sex]), -1, nil)
            sqlite3_bind_text(stmt, 13, strdup(dict[ScannedDataPrefix.state]), -1, nil)
            sqlite3_bind_text(stmt, 14, strdup(dict[ScannedDataPrefix.street]), -1, nil)
            sqlite3_bind_text(stmt, 15, strdup(dict[ScannedDataPrefix.vehicleClass]), -1, nil)
            sqlite3_bind_text(stmt, 16, strdup(dict[ScannedDataPrefix.currentDateTime]), -1, nil)
            sqlite3_bind_text(stmt, 17, strdup(dict[ScannedDataPrefix.height]), -1, nil)
            sqlite3_bind_text(stmt, 18, strdup(dict[ScannedDataPrefix.weight]), -1, nil)
            if sqlite3_step(stmt) == SQLITE_DONE{
            }
            else{
            }
            sqlite3_reset(stmt)
        }
        sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil)
        sqlite3_close(db)
    }
}

