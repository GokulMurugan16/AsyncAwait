//
//  ViewController.swift
//  AsyncAwait
//
//  Created by Gokul Murugan on 09/06/24.
//

import UIKit

struct Users:Codable{
    let name:String
    let username:String
}

class ViewController: UIViewController {
    
    private let url:String = "https://jsonplaceholder.typicode.com/users"
    
    private var users:[Users] = []
    
    private let tableView:UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        async{
            let result = await fetchUser()
            switch result{
            case .success(let users):
                self.users = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
}

enum MyError:Error{
    case UnableToConvertURL
    case DecodingFailed
}

extension ViewController{
    
    private func fetchUser() async -> Result<[Users], Error>{
        guard let url = URL(string: url) else{
            return .failure(MyError.UnableToConvertURL)
        }
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            let usersData = try JSONDecoder().decode([Users].self, from: data)
            return .success(usersData)
        } catch{
            return .failure(error)
        }
    }
}
