//
//  DateExtension.swift
//  ChatApp
//
//  Created by Dan on 7/26/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

extension Date {
    
    func convert() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: self)
    }
    
    func convertDayCalendar() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self).capitalized
    }
    
    func convertDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: self)
    }
    
}
