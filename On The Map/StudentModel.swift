//
//  StudentModel.swift
//  On The Map
//
//  Created by Paul ReFalo on 11/25/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import UIKit

class StudentModel: NSObject {
    
    // global array of Student structs
    var studentBody: [Student]
    
    override init() {
        studentBody = [Student]()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> StudentModel {
        
        struct Singleton {
            static var sharedInstance = StudentModel()
        }
        
        return Singleton.sharedInstance
    }
}
