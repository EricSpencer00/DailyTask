//
//  HealthStore.swift
//  DailyTask
//
//  Created by Eric Spencer on 6/4/24.
//

import Foundation
import HealthKit

class HealthStore {
    let healthStore = HKHealthStore()

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available")
            return
        }
        
        let readTypes = Set([
            //            HKObjectType.categoryType(forIdentifier: .medicationRecord)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        ])
        
        let writeTypes = Set([
            //HKObjectType.categoryType(forIdentifier: .medicationRecord)!,
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        ])
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if !success {
                print("Authorization failed: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func saveMedicineTracking(medicineName: String, date: Date, dosage: Double, unit: HKUnit) {
//        let medicationType = HKCategoryType.categoryType(forIdentifier: .medicationRecord)!
//        let metadata = [
//            HKMetadataKeyMedicationBrandName: medicineName,
//            HKMetadataKeyMedicationGenericName: medicineName,
//            HKMetadataKeyMedicationDosage: "\(dosage) \(unit.unitString)"
//        ]

//        let medicationSample = HKCategorySample(type: medicationType, value: HKCategoryValue.notApplicable.rawValue, start: date, end: date, metadata: metadata)

//        healthStore.save(medicationSample) { success, error in
//            if !success {
//                print("Failed to save medication record: \(String(describing: error?.localizedDescription))")
//            }
//        }
    }
}

