//
//  Doctor.swift
//  BSGNProject
//
//  Created by Linh Thai on 13/08/2024.
//

struct Doctor: Codable {
    var id: String
    var firstName: String
    var lastName: String
    var dateOfBirth: String
    var email: String
    var phoneNumber: String
    var avatar: String
    var major: String
    var star: Int
    var numberOfReviewer: Int
    var degree: String
    var gender: Int
    var address: String
    var typeOfAccount: Int = 1 // Mặc định là 1 cho doctor
}
