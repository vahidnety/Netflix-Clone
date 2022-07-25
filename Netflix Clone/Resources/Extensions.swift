//
//  Extensions.swift
//  Netflix Clone
//
//  Created by Seyedvahid Dianat on 25/07/2022.
//

import Foundation


extension String {
    
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
}
