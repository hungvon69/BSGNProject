import UIKit
import MapKit
import CoreLocation

class PositionViewController: UIViewController {


    @IBOutlet weak var detailNotePstTextField: UITextField!
    @IBOutlet weak var notConfirmButton: UIButton!
    @IBOutlet weak var confỉmButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!

    // Location Manager và Search Request
    private let locationManager = CLLocationManager()
    private let searchRequest = MKLocalSearch.Request()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Cấu hình LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    // Tìm địa điểm gần nhất dựa vào vị trí hiện tại
    private func findNearestPlace(for location: CLLocation) {
        // Không sử dụng naturalLanguageQuery để tìm kiếm tất cả địa điểm
        searchRequest.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )

        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                print("Search error: \(error.localizedDescription)")
                self.locationTextField.text = "Không thể tìm thấy địa điểm gần nhất."
                return
            }

            guard let mapItems = response?.mapItems, let firstItem = mapItems.first else {
                self.locationTextField.text = "Không có địa điểm gần đây."
                return
            }

            // Lấy tên địa điểm gần nhất và hiển thị trong TextField
            let placeName = firstItem.name ?? "Địa điểm không xác định"
            self.locationTextField.text = placeName
            print("Found place: \(placeName)")
        }
    }
    @IBAction func notConfirmTapped(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        let mapVC = GoogleMapsViewController()
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        print(GlobalService.appointmentData["patientName"])
        GlobalService.appointmentData["position"] = locationTextField.text
        GlobalService.appointmentData["positionNote"] = detailNotePstTextField.text
        GlobalService.shared.uploadAppointment { success, error in
            if success {
                print("Appointment uploaded successfully")
                
                self.showSuccessPopup()
                
            } else {
                print(error?.localizedDescription ?? "")
            }
            
        }
//        let mapVC = GoogleMapsViewController()
//        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    func showSuccessPopup() {
        // Tạo và hiển thị SuccessPopupView
        let popupView = PopUpView(frame: CGRect(x: 40, y: (view.frame.height) / 2 - 100, width: (view.frame.width) - 80, height: 250))
        
        // Đặt closure onConfirm để xử lý khi bấm nút "Xác nhận"
        popupView.onConfirm = {
            // Ẩn popup khi bấm nút xác nhận
            popupView.removeFromSuperview()
            let myappointmentVC = PatientAppointmentViewController()
            self.navigationController?.pushViewController(myappointmentVC, animated: true)
            myappointmentVC.setupNavigationBar(with: "Thông tin bác sỹ", with: false)
        }
        
        // Thêm popup vào view chính
        view.addSubview(popupView)
    }
}


// MARK: - CLLocationManagerDelegate
extension PositionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        print("User's current location: \(userLocation)")
        GlobalService.appointmentData["longitude"] = userLocation.coordinate.longitude
        GlobalService.appointmentData["latitude"] = userLocation.coordinate.latitude
        // Tìm địa điểm gần nhất từ vị trí hiện tại
        findNearestPlace(for: userLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        locationTextField.text = "Không thể lấy vị trí hiện tại."
    }
    
}
