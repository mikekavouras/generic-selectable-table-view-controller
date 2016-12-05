//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

protocol DataModel {}
protocol Selectable {
    var selected: Bool { get set }
}

class SelectableDataModel<T: DataModel>: Selectable {
    let model: T
    var selected: Bool
    
    init(model: T, selected: Bool) {
        self.model = model
        self.selected = selected
    }
}

class SelectionCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum SelectionStyle {
    case single
    case multiple
}


// generic selectable table view controller

class SelectableTableViewController<Item: Selectable, Cell: UITableViewCell>: UITableViewController {
    
    var selectionStyle: SelectionStyle = .single
    
    private let cellIdentifier = "Cell"
    private let items: [Item]
    private let configure: (Cell, Item) -> ()
    
    init(items: [Item], configure: @escaping (Cell, Item) -> ()) {
        self.items = items
        self.configure = configure
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(Cell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! Cell
        let item = items[indexPath.row]
        cell.selectionStyle = .none
        
        configure(cell, item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionStyle == .single {
            for var item in items {
                item.selected = false
            }
        }
        
        var selectedItem = items[indexPath.row]
        selectedItem.selected = !selectedItem.selected
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}




// Usage

// example data model
struct Person: DataModel {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

// create some data
let person1 = Person(name: "Duck")
let person2 = Person(name: "Jeffrey")
let person3 = Person(name: "Pudge")
let person4 = Person(name: "Santa")

// map it to SelectableDataModel
let people = [person1, person2, person3, person4].map { item in
    return SelectableDataModel(model: item, selected: item.name == "Santa")
}

// init table view controller
let tvc = SelectableTableViewController(items: people, configure: { (cell: SelectionCell, item) in
    cell.textLabel?.text = item.model.name
    cell.detailTextLabel?.text = item.selected ? "selected" : ""
})

// set selection style (.single, .multiple)
tvc.selectionStyle = .multiple

// for storyboard usability
tvc.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
PlaygroundPage.current.liveView = tvc.view
