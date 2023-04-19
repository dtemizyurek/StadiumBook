//
//  DetailsVC.swift
//  StadiumBook
//
//  Created by Doğukan Temizyürek on 17.04.2023.
//

import UIKit
import CoreData
class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var ownerText: UITextField!
    
    
    @IBOutlet weak var yearText: UITextField!
    
    @IBOutlet weak var capacityText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenStadium = ""
    var chosenStadiumId : UUID?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chosenStadium != ""
        {
            saveButton.isHidden=true
            //Core Data
            
            let appDelagate=UIApplication.shared.delegate as! AppDelegate
            let context=appDelagate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stadiums")
            let idString=chosenStadiumId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@" , idString! )
            fetchRequest.returnsObjectsAsFaults=false
            do
            {
                let results=try context.fetch(fetchRequest)
                if results.count > 0
                {
                    for result in results as! [NSManagedObject]
                    {
                        if let name=result.value(forKey: "name") as? String
                        {
                            nameText.text=name
                            
                        }
                        if let owner = result.value(forKey: "owner") as? String
                        {
                            ownerText.text=owner
                        }
                        if let year = result.value(forKey: "year") as? Int
                        {
                            yearText.text=String(year)
                        }
                        if let capacity = result.value(forKey: "capacity") as? Int                        {
                            capacityText.text=String(capacity)
                        }
                        if let imageData = result.value(forKey: "image") as? Data
                        {
                            let image = UIImage(data: imageData)
                            imageView.image=image
                        }
                        
                    }
                }
                
            }catch
            {
                print("error")
            }
            
            
        }
        else
        {
            nameText.text = ""
            ownerText.text = ""
            capacityText.text = ""
            yearText.text = ""
        }
    
        
        
        
        
        //Recognizers
        let gestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled=true
        let imageTapRecognizer=UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        hideKeyboard()
       
    }
    @objc func selectImage()
    {
        let picker=UIImagePickerController()
        picker.delegate=self
        picker.sourceType = .photoLibrary
        picker.allowsEditing=true
        present(picker,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image=info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
    }
    
    @objc func hideKeyboard()
    {
        view.endEditing(true)
    }
    
    //Kaydet Butonu
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelagete=UIApplication.shared.delegate as! AppDelegate
        let context=appDelagete.persistentContainer.viewContext
        
        let newStadium = NSEntityDescription.insertNewObject(forEntityName: "Stadiums", into: context)
        
        //Attributes
        newStadium.setValue(nameText.text! , forKey: "name")
        newStadium.setValue(ownerText.text! , forKey: "owner")
        if let year=Int(yearText.text!)
        {
            newStadium.setValue(year, forKey: "year")
        }
        if let capacity=Int(capacityText.text!)
        {
            newStadium.setValue( capacity, forKey: "capacity")
        }
        
        newStadium.setValue(UUID(), forKey: "id")
        
        let data=imageView.image!.jpegData(compressionQuality: 0.5)
        
        newStadium.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("new data"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

    


}
