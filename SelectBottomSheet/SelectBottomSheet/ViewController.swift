
import UIKit

class ViewController: UIViewController {

    let lbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.text = "gmail.com"
        return lbl
    }()
    
    lazy var btn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        btn.setTitleColor(.blue, for: .normal)
        btn.setTitleColor(.red, for: .highlighted)
        btn.setTitle("Button(select)", for: .normal)
        return btn
    }()
    
    @objc func click(_ sender: UIButton) {
        let datas = [ "naver.com",
                      "daum.net",
                      "gmail.com",
                      "hanmail.com",
                      "outlook.com",
        ]
        
        let curTitle = lbl.text ?? ""

        let action = ListTypeAction(title: "e-mail", datas: datas, curText: curTitle) { (strTitle, selectedIndex ,isSelected)  in
            
            if isSelected {
                self.lbl.text = strTitle
            }
            print(strTitle)
            print(selectedIndex)
            print(isSelected)
        }
        
        let vc = SelectSheet(action)
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(lbl)
        view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lbl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            btn.topAnchor.constraint(equalTo: lbl.bottomAnchor, constant: 20),
            btn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
    }

}

