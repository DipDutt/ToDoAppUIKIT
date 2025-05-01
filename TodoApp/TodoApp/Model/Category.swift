//
//  Category.swift
//  Todoey
//
//  Created by Dip Dutt on 27/4/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name:String = ""
    let items = List<Item>()
}
