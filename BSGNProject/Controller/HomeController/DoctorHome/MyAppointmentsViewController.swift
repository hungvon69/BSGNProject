//
//  MyAppointmentsViewController.swift
//  BSGNProject
//
//  Created by Hùng Nguyễn on 14/12/24.
//

import UIKit

class MyAppointmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myAppointmentTableView: UITableView!
    
    var appointmentID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    private func setup() {
        myAppointmentTableView.delegate = self
        myAppointmentTableView.dataSource = self
        myAppointmentTableView.registerNib(cellType: MyAppointmentTableViewCell.self)
    }
    public func configure(with appointmentID: String) {
        self.appointmentID = appointmentID
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myAppointmentTableView.dequeue(cellType: MyAppointmentTableViewCell.self, for: indexPath)
        cell.configureAppointmentPatient(with: appointmentID ?? "")
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    

}
