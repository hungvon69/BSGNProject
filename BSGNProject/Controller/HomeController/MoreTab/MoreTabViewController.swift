//
//  MoreTabViewController.swift
//  BSGNProject
//
//  Created by Hùng Nguyễn on 2/10/24.
//

import UIKit

class MoreTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet private weak var moreTabTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        moreTabTableView.delegate = self
        moreTabTableView.dataSource = self
        moreTabTableView.registerNib(cellType: MoreTabTableViewCell.self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moreTabTableView.dequeue(cellType: MoreTabTableViewCell.self, for: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 800
    }
}
