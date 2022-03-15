
import Foundation
import UIKit

// MARK: ListData
struct ListData {
    var title: String?
    var isSelected: Bool = false
}

// MARK: SelectSheet
class SelectSheet: UIViewController {
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    private lazy var viewIsDidAppear: Bool = false
    
    private lazy var viewUpdate: (viewIsDidAppear: Bool, table: CGFloat) = (false, 0) {
        didSet{
            if !viewUpdate.viewIsDidAppear { return }
            
            let viewH = view.bounds.height
            let otherH = headerTitle.bounds.height + 31
            let bottomH = getSafeAreaHeight().bottom
            let topH = getSafeAreaHeight().bottom
            
            if viewH < CGFloat(viewUpdate.table + otherH + bottomH + topH ) {
                tableViewConstraintHeigh?.constant = CGFloat(viewH - otherH - bottomH - topH )
                
            }else{
                tableViewConstraintHeigh?.constant = viewUpdate.table
            }
            
            contentsViewConstraintTop?.constant = CGFloat(-(tableViewConstraintHeigh?.constant ?? 0) - otherH - bottomH )
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                
                self.view.backgroundColor = UIColor(white: 0, alpha: 0.6)
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    private var settingData: [ListData] = [ListData]()
    private var action: ListTypeAction!
    private var contentsViewConstraintTop  : NSLayoutConstraint?
    private var contentsViewConstraintHeigh: NSLayoutConstraint?
    private var tableViewConstraintHeigh   : NSLayoutConstraint?
    private let cellId = "cellId"
    
    private let contentsView: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.backgroundColor = UIColor.white
        uv.layer.cornerRadius = 1.0
        uv.clipsToBounds = true
        uv.layer.cornerRadius = 13
        return uv
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate   = self
        tv.dataSource = self
        tv.showsVerticalScrollIndicator = false
        tv.separatorStyle = .none
        tv.register(SelectSheetTableViewCell.self, forCellReuseIdentifier: cellId )
        tv.backgroundColor = UIColor.clear
        tv.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        return tv
    }()
    
    private let dimBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.clear
        btn.addTarget(self, action: #selector(dimClick), for: .touchUpInside)
        return btn
    }()
    
    private let headerTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.black
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.textAlignment = .left
        return lbl
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(_ addAction: ListTypeAction){
        self.init(nibName: nil, bundle: nil)
        self.action = addAction
        
        self.modalTransitionStyle   = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.0)
        
        self.headerTitle.text = action.title ?? ""
        
        if let arrs = action.datas, let index = action.nSelectedIdx {
            for i in 0..<arrs.count {
                
                var isSelected = false
                if i == index {
                    isSelected = true
                }
                
                let title = arrs[i]
                let cellType = ListData(title: title, isSelected: isSelected)

                self.settingData.append(cellType)
            }
        }
        
        self.view.addSubview(dimBtn)
        self.view.addSubview(contentsView)
        
        NSLayoutConstraint.activate([
            dimBtn.topAnchor.constraint(equalTo: view.topAnchor),
            dimBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            contentsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        contentsViewConstraintTop = contentsView.topAnchor.constraint(equalTo: view.bottomAnchor)
        contentsViewConstraintTop?.isActive = true
        contentsView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        let bottomLine = UILabel()
        bottomLine.backgroundColor = UIColor.gray
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.contentsView.addSubview(headerTitle)
        self.contentsView.addSubview(bottomLine)
        self.contentsView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            headerTitle.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor, constant: 25),
            headerTitle.trailingAnchor.constraint(equalTo: contentsView.trailingAnchor, constant: -25),
            headerTitle.topAnchor.constraint(equalTo: contentsView.topAnchor, constant: 15),
            
            bottomLine.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor, constant: 15),
            bottomLine.trailingAnchor.constraint(equalTo: contentsView.trailingAnchor, constant: -15),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            bottomLine.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 15),
            
            tableView.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: contentsView.trailingAnchor, constant: -15),
            tableView.topAnchor.constraint(equalTo: bottomLine.bottomAnchor),
        ])
        tableViewConstraintHeigh = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewConstraintHeigh?.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewUpdate.viewIsDidAppear = true
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    
        contentsViewConstraintTop?.constant = CGFloat(-(contentsViewConstraintTop?.constant)!)
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.backgroundColor = UIColor(white: 0, alpha: CGFloat(0))
            self.view.layoutIfNeeded()
            
            if flag {
                if let handler = self.action.completionHandlers{
                    handler( "" , -1, false )
                }
            }
            
        }) { (_) in
            super.dismiss(animated: false, completion: completion)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newValue = change?[.newKey], let newSize = newValue as? CGSize {
                viewUpdate.table = newSize.height
            }
        }
    }

    @objc func dimClick(){
        self.dismiss(animated: true, completion: nil)
    }
    
    public func addAction(_ action: ListTypeAction){
        self.action = action
    }
    
    func getSafeAreaHeight() -> (top: CGFloat, bottom: CGFloat) {
        let window = UIApplication.shared.keyWindow
        let bottom = window?.safeAreaInsets.bottom
        let top    = window?.safeAreaInsets.top
        return (top ?? 0, bottom ?? 0)
    }
    
}

// MARK: SelectSheet (UITableViewDelegate, UITableViewDataSource)
extension SelectSheet : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData: ListData = settingData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SelectSheetTableViewCell
        cell.cellDataRow = cellData
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let handler = self.action.completionHandlers{
            if let arrStr = self.action.datas {
                if indexPath.row <= arrStr.count {
                    let str = arrStr[indexPath.row]
                    handler( str , indexPath.row, true )
                }
            }
        }
        self.dismiss(animated: false, completion: nil)
        
    }
    
}

// MARK: ListTypeAction
class ListTypeAction {
    var title       : String?
    var datas       : [String]?
    var nSelectedIdx: Int?
    var completionHandlers: ((String, Int, Bool) -> Void)?

    init(title: String, datas: [String], curText: String, handler: ((String, Int, Bool) -> ())? ){
        self.title         = title
        self.datas         = datas
        self.nSelectedIdx  = datas.firstIndex(of: curText) ?? -1
        completionHandlers = handler
    }
}

// MARK: SelectSheetTableViewCell
class SelectSheetTableViewCell: UITableViewCell {

    let lblText : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 20)
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        contentView.addSubview(lblText)
        NSLayoutConstraint.activate([
            lblText.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            lblText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            lblText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            lblText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
    
    var cellDataRow: ListData! {
        didSet{
            lblText.text = cellDataRow.title
            lblText.textColor = cellDataRow.isSelected ? UIColor.red : UIColor.black
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
