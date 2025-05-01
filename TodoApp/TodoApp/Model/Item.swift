//
//  Item.swift
//  Todoey
//
//  Created by Dip Dutt on 27/4/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title:String = ""
    @objc dynamic var isDone:Bool = false
    @objc dynamic var date:Date?
    var parentCategory = LinkingObjects(fromType:Category.self, property: "items")
}
