import Firebase
import UIKit
import FirebaseDatabase
import FirebaseAuth

import FirebaseStorage

class GlobalService {
    static var appointmentData: [String: Any] = [
        "id": "00",
        "doctorID": "00",
        "patientID": "00",
        "doctorName": "00",
        "patientName": "00",
        "specialty": "00",
        "date": "00",
        "price": "00",
        "status": "00"

    ]
    static let shared = GlobalService()
    private let databaseRef = Database.database().reference().child("users")
    private let storage = Storage.storage().reference()
    private let database = Database.database().reference()
    
    private init() {}
    
    // MARK: - Register User
    func registerUser(email: String, password: String, isDoctor: Bool, additionalInfo: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = authResult?.user.uid else {
                completion(.failure(NSError(domain: "UserIDError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve user ID."])))
                return
            }
            
            // Set typeOfAccount based on user role
            var userInfo = additionalInfo
            userInfo["id"] = uid
            userInfo["typeOfAccount"] = isDoctor ? 1 : 0
            
            let userTypeRef = isDoctor ? self.databaseRef.child("doctors").child(uid) : self.databaseRef.child("patients").child(uid)
            userTypeRef.setValue(userInfo) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Fetch User Data
    func fetchUserData(uid: String, isDoctor: Bool, completion: @escaping (Result<Any, Error>) -> Void) {
        let userTypeRef = isDoctor ? self.databaseRef.child("doctors").child(uid) : self.databaseRef.child("patients").child(uid)
        
        userTypeRef.observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                completion(.failure(NSError(domain: "UserDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found."])))
                return
            }
            
            do {
                if isDoctor {
                    let doctorData = try JSONDecoder().decode(Doctor.self, from: JSONSerialization.data(withJSONObject: userData))
                    completion(.success(doctorData))
                } else {
                    let patientData = try JSONDecoder().decode(Patient.self, from: JSONSerialization.data(withJSONObject: userData))
                    completion(.success(patientData))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Update User Data
    func updateUserData(uid: String, isDoctor: Bool, updatedData: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let userTypeRef = isDoctor ? self.databaseRef.child("doctors").child(uid) : self.databaseRef.child("patients").child(uid)
        
        userTypeRef.updateChildValues(updatedData) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                completion(.success(authResult))
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    func uploadAvatar(imageData: Data, typeOfAccount: String, completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is logged in.")
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        // Lưu avatar vào Storage với UID của người dùng
        let avatarRef = storage.child("avatars/\(currentUser.uid).jpg")
        
        avatarRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            // Lấy URL của ảnh đã upload
            avatarRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to retrieve download URL: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                guard let downloadURL = url else {
                    print("Download URL is nil")
                    completion(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Download URL is nil"]))
                    return
                }
                
                // Lấy typeOfAccount từ Realtime Database để xác định là doctor hay patient
                self.database.child("users").child(typeOfAccount).child(currentUser.uid).observeSingleEvent(of: .value) { snapshot in
                    guard let userData = snapshot.value as? [String: Any] else {
                        print("Snapshot is nil or not a dictionary")
                        completion(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Snapshot is nil or not a dictionary"]))
                        return
                    }
                    
                    print("User data: \(userData)") // In ra toàn bộ dữ liệu để kiểm tra

                    guard let typeOfAccount = userData["typeOfAccount"] as? Int else {
                        print("typeOfAccount is missing or invalid")
                        completion(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "typeOfAccount is missing or invalid"]))
                        return
                    }
                    
                    let userBranch = (typeOfAccount == 1) ? "doctors" : "patients"
                    let userRef = self.database.child("users").child(userBranch).child(currentUser.uid)
                    
                    userRef.updateChildValues(["avatar": downloadURL.absoluteString]) { error, _ in
                        if let error = error {
                            print("Failed to update avatar URL in Realtime Database: \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("Avatar URL successfully updated in Realtime Database")
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    func fetchAppointments(completion: @escaping ([Appointment]) -> Void) {
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            var appointments: [Appointment] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any],
                   let doctorID = data["doctorID"] as? String,
                   let doctorName = data["doctorName"] as? String,
                   let patientID = data["patientID"] as? String,
                   let patientName = data["patientName"] as? String,
                   let specialty = data["specialty"] as? String,
                   let price = data["price"] as? Double,
                   let dateStr = data["date"] as? String,
                   let statusStr = data["status"] as? String,
                   let status = AppointmentStatus(rawValue: statusStr),
                   let date = ISO8601DateFormatter().date(from: dateStr) {
                    
                    let appointment = Appointment(
                        id: childSnapshot.key,
                        doctorID: doctorID,
                        doctorName: doctorName,
                        patientID: patientID,
                        patientName: patientName,
                        specialty: specialty,
                        price: price,
                        date: date,
                        status: status
                    )
                    appointments.append(appointment)
                }
            }
            completion(appointments)
        }
    }
    func fetchDoctorProfile(uid: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        // Truy cập vào đường dẫn của doctor trong Firebase
        let doctorRef = self.databaseRef.child("doctors").child(uid)
        
        doctorRef.observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                completion(.failure(NSError(domain: "UserDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Doctor data not found."])))
                return
            }
            
            // Lấy URL avatar và tên từ dữ liệu Firebase
            guard let avatarURL = userData["avatar"] as? String,
                  let name = userData["firstName"] as? String else {
                completion(.failure(NSError(domain: "DataError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Missing avatar or name"])))
                return
            }
            
            // Trả về URL avatar và tên
            completion(.success((avatarURL, name)))
        }
    }

}
