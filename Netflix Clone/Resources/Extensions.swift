//
//  Extensions.swift
//  Netflix Clone
//
//  Created by Seyedvahid Dianat on 25/07/2022.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        prefix(1).uppercased() + lowercased().dropFirst()
    }
}
