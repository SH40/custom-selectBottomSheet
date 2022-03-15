# custom-alert

## capture image
<img src="https://user-images.githubusercontent.com/43785575/158384553-b0f6b2c3-3833-4bba-a9f1-e9a7c6b97bf7.png" width="300" height="649">

<br>

## how to use
```swift
let datas = [ "naver.com",
              "daum.net",
              "gmail.com",
              "hanmail.com",
              "outlook.com",
            ]
        
let curTitle = "outlook.com"

let action = ListTypeAction(title: "e-mail", datas: datas, curText: curTitle) { (strTitle, selectedIndex ,isSelected)  in
    if isSelected {
        self.lbl.text = strTitle
    }
}

let vc = SelectSheet(action)
self.present(vc, animated: true, completion: nil)
```
