//
//  ViewController.swift
//  StadiumBook
//
//  Created by Doğukan Temizyürek on 16.04.2023.
//

import UIKit

import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var nameArray=[String]()
    var idArray=[UUID]()

    var selectedStadium = ""
    var selectedStadiumId : UUID?
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "new data"), object: nil)
    }
    
    @objc func getData()
    {
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        let appDelagete = UIApplication.shared.delegate as! AppDelegate
        let context=appDelagete.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stadiums")
        
        fetchRequest.returnsObjectsAsFaults=false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                for result in results as! [NSManagedObject] {
                    if let name =   result.value(forKey: "name") as? String
                    {
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID
                    {
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
            
        }catch
        {
            print("error")
        }
        
        
            
    }
    
    

    @objc func addButtonClicked()
    {
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=UITableViewCell()
        cell.textLabel?.text=nameArray[indexPath.row]
        return cell
       
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="toDetailsVC"
        {
            let destinationVC=segue.destination as! DetailsVC
            destinationVC.chosenStadium=selectedStadium
            destinationVC.chosenStadiumId=selectedStadiumId
            
            
        }
    }
    //Segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStadium=nameArray[indexPath.row]
        selectedStadiumId=idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    //Veri silme
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let appDelagete = UIApplication.shared.delegate as! AppDelegate
            let context = appDelagete.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stadiums")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@ ", idString)
        
            do
            {
                let results = try context.fetch(fetchRequest)
                if results.count > 0
                {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID
                        {
                            if id == idArray[indexPath.row]
                            {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                            }
                            break
                        }
                    }
                }
                
            }catch
            {
                print("error")
            }
                
        
            
            
        }
    }

    
}

