//
//  Helper.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import Foundation
import SwiftUI

let types = ["Rosuvastatin", "Metformin", "Losartan", "Latanoprost", "Water", "Smoothie", "Protein"]

//let amounts: [Double] = [0.5, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 20, 25, 50, 100, 200, 500, 1000]

let units: [String] = ["mg", "fluid ounces", "cups", "g", "ozs", "ml", "liters", "pills", "drops"]

let frequencies: [String] = ["Once daily", "Twice daily", "Three times daily", "Six times daily", "Once a week", "twice a week", "three times a week"]

let matchingUnitsDictionary: Dictionary<String, String> = ["Rosuvastatin": "mg", "Metformin": "mg", "Losartan": "mg", "Latanoprost": "drops", "Water": "fluid ounces", "Smoothie": "fluid ounces", "Protein": "g"]


let matchingAmountDictionary: Dictionary<String, Double> = ["Rosuvastatin": 20.0, "Metformin": 500.0, "Losartan": 25.0, "Latanoprost": 1.0, "Water": 14, "Smoothie": 14, "Protein": 14]

let matchingDescriptionDictionary: Dictionary<String, String> = ["Rosuvastatin": "Cholesterol-lowering medication", "Metformin": "Glucose-lowering medication", "Losartan": "Blood pressure-lowering medication", "Latanoprost": "Eye pressure reduction medication", "Water": "Hydration, kidney function support", "Smoothie": "Nutrient-rich beverage", "Protein": "Essential amino acid supplement"]


let matchingFrequencyDictionary: Dictionary<String, String> = ["Rosuvastatin": "Once daily", "Metformin": "twice daily", "Losartan": "Once daily", "Latanoprost": "Once daily, evening", "Water": "Six times daily", "Smoothie": "Once daily", "Protein": "Once daily"]
