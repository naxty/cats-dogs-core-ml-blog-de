//
//  PredictionResult.swift
//  ImagePredictionDemo
//
//  Created by Nico Company on 17.04.19.
//

import Foundation

class PredictionResult {
    var classLabel: String
    var probabilties: Dictionary<String, Double>
    
    init(label: String, probs: Dictionary<String, Double>){
        classLabel = label
        probabilties = probs
    }
}
