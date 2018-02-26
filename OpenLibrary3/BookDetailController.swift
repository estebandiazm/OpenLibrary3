//
//  BookDetailController.swift
//  OpenLibrary3
//
//  Created by Juan Esteban Diaz Montejo on 25/02/18.
//  Copyright © 2018 Juan Esteban Diaz Montejo. All rights reserved.
//

import UIKit

class BookDetailController: UIViewController {
    
    var isbnBook = "";
    var isConnError:Bool = false
    private var isNew:Bool = false
    var mainController:TableViewController?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var isbnField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!isbnBook.isEmpty){
            searchBookData()
            isbnField.text = isbnBook
            isbnField.endEditing(false)
            searchButton.isHidden = true
            self.isNew = true
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (isNew){
            let parent = segue.destination as! TableViewController
            parent.books.append([titleLabel.text!,isbnBook])
        }
    }
 
    
    func callService(isbnBook:NSString) -> Data?{
        let paht = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"+(isbnBook as String)
        print(paht)
        let url = NSURL(string:paht)
        let datos:NSData? = NSData(contentsOf: url! as URL)
        if datos == nil {
            return nil
        }
        return (datos! as Data?)!
    }
    @IBAction func searchButtonAction(_ sender: Any) {
        isbnBook = isbnField!.text!
        searchBookData()
//        if (titleLabel.text?.isEmpty)!{
            mainController?.books.append([(titleLabel?.text)!,isbnBook])
            mainController?.tableView.reloadData()
//        }
    }
    
    func searchBookData(){
        do{
            let data = callService(isbnBook: isbnBook as NSString) as Data?
            if nil != data {
                let json = try JSONSerialization.jsonObject(with:data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                let rootJson = json as! NSDictionary
                let book:NSDictionary? = rootJson["ISBN:"+isbnBook] as? NSDictionary
                if book != nil {
                    let title = book!["title"] as! NSString as String
                    print(title)
                    titleLabel.text = title
                    let authors = book!["authors"] as! [[String:Any]]
                    setAuthors(authors: authors)
                    let covers = book!["cover"] as! NSDictionary?
                    if nil != covers {
                        let coverURL = covers!["medium"] as!NSString as String
                        downloadImage(coverURL)
                    }
                }
            } else {
                isConnError = true
            }
            
        }
        catch _ {
            
        }
    }
    
    func setAuthors(authors:[[String:Any]]){
        authorsLabel.text = ""
        for i in 0...authors.count - 1  {
            let author = authors[i]["name"] as! NSString as String
            print(author)
            authorsLabel.text = authorsLabel.text?.appending("\n\(author)")
        }
    }
    
    func downloadImage(_ uri : String){
        
        let url = URL(string: uri)
        
        let task = URLSession.shared.dataTask(with: url!) {responseData,response,error in
            if error == nil{
                if let data = responseData {
                    
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                    
                }else {
                    print("no data")
                }
            }else{
                print(error as Any)
            }
        }
        
        task.resume()
        
    }

}
