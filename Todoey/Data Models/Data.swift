//
//  Data.swift
//  Todoey
//
//  Created by Mark Marvin Blanca on 3/15/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Data: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}
