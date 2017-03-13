//
//  TableViewController.swift
//  Linkage
//
//  Created by LeeJay on 2017/3/3.
//  Copyright © 2017年 LeeJay. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    fileprivate lazy var leftTableView : UITableView = {
        let leftTableView = UITableView()
        leftTableView.delegate = self
        leftTableView.dataSource = self
        leftTableView.frame = CGRect(x: 0, y: 0, width: 80, height: ScreenHeight)
        leftTableView.rowHeight = 55
        leftTableView.showsVerticalScrollIndicator = false
        leftTableView.separatorColor = UIColor.clear
        leftTableView.register(LeftTableViewCell.self, forCellReuseIdentifier: kLeftTableViewCell)
        return leftTableView
    }()
    
    fileprivate lazy var rightTableView : UITableView = {
        let rightTableView = UITableView()
        rightTableView.delegate = self
        rightTableView.dataSource = self
        rightTableView.frame = CGRect(x: 80, y: 64, width: ScreenWidth - 80, height: ScreenHeight - 64)
        rightTableView.rowHeight = 80
        rightTableView.showsVerticalScrollIndicator = false
        rightTableView.register(RightTableViewCell.self, forCellReuseIdentifier: kRightTableViewCell)
        return rightTableView
    }()
    
    fileprivate lazy var categoryData = [CategoryModel]()
    fileprivate lazy var foodData = [[FoodModel]]()
    
    fileprivate var selectIndex = 0
    fileprivate var isScrollDown = true
    fileprivate var lastOffsetY : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        configureData()
        
        view.addSubview(leftTableView)
        view.addSubview(rightTableView)
        
        leftTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
    }
}

//MARK: - 获取数据
extension TableViewController {
    
    fileprivate func configureData () {
        
        guard let path = Bundle.main.path(forResource: "meituan", ofType: "json") else { return }
        
        guard let data = NSData(contentsOfFile: path) as? Data else { return }
        
        guard let anyObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return }
        
        guard let dict = anyObject as? [String : Any] else { return }
        
        guard let datas = dict["data"] as? [String : Any] else { return }
        
        guard let foods = datas["food_spu_tags"] as? [[String : Any]] else { return }
        
        for food in foods {
            
            let model = CategoryModel(dict: food)
            categoryData.append(model)
            
            guard let spus = model.spus else { continue }
            var datas = [FoodModel]()
            for fModel in spus {
                datas.append(fModel)
            }
            foodData.append(datas)
        }
    }    
}

//MARK: - TableView DataSource Delegate
extension TableViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if leftTableView == tableView {
            return 1
        } else {
            return categoryData.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if leftTableView == tableView {
            return categoryData.count
        } else {
            return foodData[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if leftTableView == tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: kLeftTableViewCell, for: indexPath) as! LeftTableViewCell
            let model = categoryData[indexPath.row]
            cell.nameLabel.text = model.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kRightTableViewCell, for: indexPath) as! RightTableViewCell
            let model = foodData[indexPath.section][indexPath.row]
            cell.setDatas(model)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if leftTableView == tableView {
            return 0
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if leftTableView == tableView {
            return nil
        }
        let headerView = TableViewHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 20))
        let model = categoryData[section]
        headerView.nameLabel.text = model.name
        return headerView
    }
    
    // TableView分区标题即将展示
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // 当前的tableView是RightTableView，RightTableView滚动的方向向上，RightTableView是用户拖拽而产生滚动的（（主要判断RightTableView用户拖拽而滚动的，还是点击LeftTableView而滚动的）
        if (rightTableView == tableView) && !isScrollDown && rightTableView.isDragging {
            selectRow(index: section)
        }
    }
    
    // TableView分区标题展示结束
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // 当前的tableView是RightTableView，RightTableView滚动的方向向下，RightTableView是用户拖拽而产生滚动的（（主要判断RightTableView用户拖拽而滚动的，还是点击LeftTableView而滚动的）
        if (rightTableView == tableView) && isScrollDown && rightTableView.isDragging {
            selectRow(index: section + 1)
        }
    }
    
    // 当拖动右边TableView的时候，处理左边TableView
    private func selectRow(index : Int) {
        leftTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if leftTableView == tableView {
            selectIndex = indexPath.row
            rightTableView.scrollToRow(at: IndexPath(row: 0, section: selectIndex), at: .top, animated: true)
            leftTableView.scrollToRow(at: IndexPath(row: selectIndex, section: 0), at: .top, animated: true)
        }
    }
    
    // 标记一下 RightTableView 的滚动方向，是向上还是向下
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let tableView = scrollView as! UITableView
        if rightTableView == tableView {
            isScrollDown = lastOffsetY < scrollView.contentOffset.y
            lastOffsetY = scrollView.contentOffset.y
        }
    }
}
