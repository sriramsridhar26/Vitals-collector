//
//  HeartRateMeasurementService.swift
//  HeartRate WatchKit Extension
//
//  Created by Anastasia Ryabenko on 27.01.2021.
//

import Foundation
import SwiftUI
import HealthKit

class HeartRateMeasurementService: ObservableObject {
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    
    @Published var currentHeartRate: Int = 0
    @Published var minHeartRate: Int = -1
    @Published var maxHeartRate: Int = 0
    
    /* Blood Oxygen
    @Published var currentBloodOxygen: Int = 0
    @Published var minBloodOxygen: Int = -1
    @Published var maxBloodOxygen: Int = 0
    */
    init() {
        autorizeHealthKit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
     //   startBO2Query(quantityTypeIdentifier: .oxygenSaturation)
       
    }
    
    func autorizeHealthKit() {
        let healthKitTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
        //    HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)! // Blood Oxygen
        ]

        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            self.heartprocess(samples, type: quantityTypeIdentifier)
        }
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        healthStore.execute(query)
    }
    
    private func heartprocess(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
                print(lastHeartRate)
            }
            DispatchQueue.main.async {
                self.currentHeartRate = Int(lastHeartRate)
                
                if self.maxHeartRate < self.currentHeartRate {
                    self.maxHeartRate = self.currentHeartRate
                }
                if self.minHeartRate == -1 || self.minHeartRate > self.currentHeartRate {
                    self.minHeartRate = self.currentHeartRate
                }
            }
        }
    }
    /* Blood Oxygen
    private func startBO2Query(quantityTypeIdentifier: HKQuantityTypeIdentifier){
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            print(samples.count)
            self.oxygenprocess(samples, type: quantityTypeIdentifier)
        }
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        healthStore.execute(query)
    }
    private func oxygenprocess(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier){
        var lastoxygenval = 0.0
        for sample in samples{
            if type == .oxygenSaturation{
                lastoxygenval = sample.quantity.doubleValue(for: .percent()) * 100
//                print(lastoxygenval)
            }
            DispatchQueue.main.async {
                self.currentBloodOxygen = Int(lastoxygenval)
                if self.maxBloodOxygen < self.currentBloodOxygen {
                    self.maxBloodOxygen = self.currentBloodOxygen
                }
                if self.minBloodOxygen == -1 || self.minBloodOxygen > self.currentBloodOxygen {
                    self.minBloodOxygen = self.currentBloodOxygen
                }
            }
            
        }
    }
     */
}
