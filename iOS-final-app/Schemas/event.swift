//
//  event.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/21/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import Foundation
import MapKit

class Game : MKPointAnnotation {
    
    var gameTitle: String?
    var location: CLLocationCoordinate2D?
    var sport: String?
    var creator: String?
    var start: Date?
    var end: Date?
    var desc: String?
    var isPrivate: Bool?
    var attendees: [String]?
    var id: String?
    
    init(id: String?, title: String, coordinate: CLLocationCoordinate2D?, sport: String, creator: String?, start: Date, end: Date, desc: String, isPrivate: Bool, attendees: [String]?) {
        super.init()
        self.id = id
        self.gameTitle = title
        self.location = coordinate
        self.coordinate = coordinate!
        self.sport = sport
        self.creator = creator
        self.start = start
        self.end = end
        self.desc = desc
        self.isPrivate = isPrivate
        self.attendees = attendees
    }
    
    func setAttendees(attendees: [String]) {
        self.attendees = attendees
    }
}

enum Sport: String {
    case soccer = "soccer"
    case basketball = "basketball"
    case football = "football"
    case tennis = "tennis"
    case baseball = "baseball"
    case volleyball = "volleyball"
    case other = "other"
}
