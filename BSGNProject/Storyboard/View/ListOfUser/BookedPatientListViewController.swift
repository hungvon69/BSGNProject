//
//  BookedPatientListViewController.swift
//  BSGNProject
//
//  Created by Hùng Nguyễn on 23/10/24.
//

import UIKit

class BookedPatientListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet private weak var bookedPatientListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bookedPatientListTableView.delegate = self
        bookedPatientListTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookedPatientListTableViewCell", for: indexPath)
        return cell
    }

}
