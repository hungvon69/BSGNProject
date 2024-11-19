//
//  Patient.swift
//  BSGNProject
//
//  Created by Hùng Nguyễn on 5/11/24.
//

import Foundation
struct Patient: Codable {
    var id: String
    var fullName: String
    var name: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var address: String
    var provide: String
    var district: String
    var dateOfBirth: String
    var avatar: String
    var sex: Int
    var blood: Int
    var typeOfAccount: Int = 0 // Mặc định là 0 cho patient
}
