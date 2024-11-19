//
//  Appointment.swift
//  BSGNProject
//
//  Created by Hùng Nguyễn on 4/11/24.
//

import Foundation

enum AppointmentStatus: String {
    case pending
    case confirmed
    case closed
}

struct Appointment {
    let id: String
    let doctorID: String
    let doctorName: String
    let patientID: String
    let patientName: String
    let specialty: String
    let price: Double
    let date: Date
    var status: AppointmentStatus
    
    init(id: String = UUID().uuidString,
         doctorID: String,
         doctorName: String,
         patientID: String,
         patientName: String,
         specialty: String,
         price: Double,
         date: Date,
         status: AppointmentStatus = .pending) {
        self.id = id
        self.doctorID = doctorID
        self.doctorName = doctorName
        self.patientID = patientID
        self.patientName = patientName
        self.specialty = specialty
        self.price = price
        self.date = date
        self.status = status
    }
    
    // Chuyển đổi dữ liệu thành dictionary để lưu vào Firebase
    func toDictionary() -> [String: Any] {
        return [
            "doctorID": doctorID,
            "doctorName": doctorName,
            "patientID": patientID,
            "patientName": patientName,
            "specialty": specialty,
            "price": price,
            "date": ISO8601DateFormatter().string(from: date),
            "status": status.rawValue
        ]
    }
}
