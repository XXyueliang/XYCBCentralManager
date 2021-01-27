//
//  collectionViewVC.swift
//  十六进制键盘
//
//  Created by macvivi on 2021/1/8.
//

import UIKit

class CollectionViewVC: UIViewController {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    typealias StrClosure = (String) -> Void
    var backClosure: StrClosure?
    
    func addRightBarBtnItem() {
        let item = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(rightBarBtnItemClick));
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc func rightBarBtnItemClick() {
        backClosure!(textView.text)
        navigationController?.popViewController(animated: true)
    }
    
    let content = "0123456789abcdef"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "编辑（collectionView）"
        addRightBarBtnItem()
        setupUI()
        collectionView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView.isHidden = false
        collectionView.collectionViewLayout = layout
        addCancelBtn()
    }
    
    func setupUI() {
        textView.delegate = self
        textView.becomeFirstResponder()
        textView.inputView = UIView()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func addCancelBtn() {
        let btn = UIButton(frame: CGRect(x: view.width - 50, y: collectionView.y - 60, width: 50, height: 50))
        btn.setImage(UIImage(named: "删除"), for: .normal)
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
    }
    
    @objc func btnClick(btn: UIButton) {
        if textView.text.count > 0 {
            textView.text.removeLast()
        }
        if textView.text.count > 0 {
            placeholderLabel.isHidden = true
        }else {
            placeholderLabel.isHidden = false
        }
    }

    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: collectionView.width/4.1, height: collectionView.height/4.1)
        
        return layout
    }()
}

extension CollectionViewVC: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ContentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as! ContentCell
        let index = content.index(content.startIndex, offsetBy: indexPath.row)
        cell.contentLabel.text = String(content[index...index])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: ContentCell = collectionView.cellForItem(at: indexPath)! as! ContentCell
        
        textView.text += cell.contentLabel.text!
        placeholderLabel.isHidden = true
    }
    
}


extension CollectionViewVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print(#function)
        if textView.text.count > 0 {
            placeholderLabel.isHidden = true
        }else {
            placeholderLabel.isHidden = false
        }
    }
}
