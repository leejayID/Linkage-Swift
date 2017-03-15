#【Swift 联动】：两个 TableView 之间的联动，TableView 与 CollectionView 之间的联动

## 前言
之前用 Objective-C 写了一篇联动的 demo 和文章，后来有小伙伴私信我有没有 Swfit 语言的，最近趁晚上和周末学习了一下 Swift 3.0 的语法，写了一个 Swift 的 demo。
思路和 [Objective-C 版本的联动文章](http://www.jianshu.com/p/7e534656988d)一样，实现的效果也是一样。先来看下效果图。

![联动.gif](http://upload-images.jianshu.io/upload_images/1321491-c779e8ced78e89c0.gif?imageMogr2/auto-orient/strip)

## 正文

### 一、TableView 与 TableView 之间的联动
下面来说下实现两个 TableView 之间联动的主要思路：
先解析数据装入模型。

```swift
// 数据校验
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
```

定义两个 TableView：LeftTableView 和 RightTableView。

```swift
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
```
先将左边的 TableView 关联右边的 TableView：点击左边的 TableViewCell，右边的 TableView 跳到相应的分区列表头部。

```swift
func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
   if leftTableView == tableView {
       return nil
   }
   let headerView = TableViewHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 20))
   let model = categoryData[section]
   headerView.nameLabel.text = model.name
   return headerView
}
```
再将右边的 TableView 关联左边的 TableView：标记一下RightTableView 的滚动方向，然后分别在 TableView 分区标题即将展示和展示结束的代理函数里面处理逻辑。

* 1.在 TableView 分区标题即将展示里面，判断当前的 tableView 是 RightTableView，RightTableView 滑动的方向向上，RightTableView 是用户拖拽而产生滚动的（主要判断RightTableView 是用户拖拽的，还是点击 LeftTableView 滚动的），如果三者都成立，那么 LeftTableView 的选中行就是 RightTableView 的当前 section。
* 2.在 TableView 分区标题展示结束里面，判断当前的 tableView 是 RightTableView，滑动的方向向下，RightTableView 是用户拖拽而产生滚动的，如果三者都成立，那么 LeftTableView 的选中行就是 RightTableView 的当前 section-1。

```swift
// 标记一下 RightTableView 的滚动方向，是向上还是向下
func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
   let tableView = scrollView as! UITableView
   if rightTableView == tableView {
       isScrollDown = lastOffsetY < scrollView.contentOffset.y
       lastOffsetY = scrollView.contentOffset.y
   }
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
```
这样就实现了两个 TableView 之间的联动，是不是很简单。

### 二、TableView 与 CollectionView 之间的联动

TableView 与 CollectionView 之间的联动与两个 TableView 之间的联动逻辑类似。
下面说下实现 TableView 与 CollectionView 之间的联动的主要思路：
还是一样，先解析数据装入模型。

```swift
// 数据校验
guard let path = Bundle.main.path(forResource: "liwushuo", ofType: "json") else { return }
        
guard let data = NSData(contentsOfFile: path) as? Data else { return }
   
guard let anyObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return }
   
guard let dict = anyObject as? [String : Any] else { return }
   
guard let datas = dict["data"] as? [String : Any] else { return }
   
guard let categories = datas["categories"] as? [[String : Any]] else { return }
   
for category in categories {
  let model = CollectionCategoryModel(dict: category)
  dataSource.append(model)
  
  guard let subcategories = model.subcategories else { continue }
  
  var datas = [SubCategoryModel]()
  for subcategory in subcategories {
      datas.append(subcategory)
  }
  collectionDatas.append(datas)
}
```

定义一个 TableView，一个 CollectionView。

```swift
fileprivate lazy var tableView : UITableView = {
   let tableView = UITableView()
   tableView.delegate = self
   tableView.dataSource = self
   tableView.frame = CGRect(x: 0, y: 0, width: 80, height: ScreenHeight)
   tableView.rowHeight = 55
   tableView.showsVerticalScrollIndicator = false
   tableView.separatorColor = UIColor.clear
   tableView.register(LeftTableViewCell.self, forCellReuseIdentifier: kLeftTableViewCell)
   return tableView
}()
    
fileprivate lazy var flowlayout : LJCollectionViewFlowLayout = {
    let flowlayout = LJCollectionViewFlowLayout()
    flowlayout.scrollDirection = .vertical
    flowlayout.minimumLineSpacing = 2
    flowlayout.minimumInteritemSpacing = 2
    flowlayout.itemSize = CGSize(width: (ScreenWidth - 80 - 4 - 4) / 3, height: (ScreenWidth - 80 - 4 - 4) / 3 + 30)
    flowlayout.headerReferenceSize = CGSize(width: ScreenWidth, height: 30)
    return flowlayout
}()

fileprivate lazy var collectionView : UICollectionView = {
    let collectionView = UICollectionView(frame: CGRect.init(x: 2 + 80, y: 2 + 64, width: ScreenWidth - 80 - 4, height: ScreenHeight - 64 - 4), collectionViewLayout: self.flowlayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = UIColor.clear
    collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: kCollectionViewCell)
    collectionView.register(CollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kCollectionViewHeaderView)
    return collectionView
}()

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(withIdentifier: kLeftTableViewCell, for: indexPath) as! LeftTableViewCell
   let model = dataSource[indexPath.row]
   cell.nameLabel.text = model.name
   return cell
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionViewCell, for: indexPath) as! CollectionViewCell
   let model = collectionDatas[indexPath.section][indexPath.row]
   cell.setDatas(model)
   return cell
}
```
先将 TableView 关联 CollectionView，点击 TableViewCell，右边的 CollectionView 跳到相应的分区列表头部。

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndex = indexPath.row
   collectionView.scrollToItem(at: IndexPath(row: 0, section: selectIndex), at: .top, animated: true)
   tableView.scrollToRow(at: IndexPath(row: selectIndex, section: 0), at: .top, animated: true)
}
```
再将 CollectionView 关联 TableView，标记一下 RightTableView 的滚动方向，然后分别在 CollectionView 分区标题即将展示和展示结束的代理函数里面处理逻辑。

* 1.在 CollectionView 分区标题即将展示里面，判断 当前 CollectionView 滚动的方向向上， CollectionView 是用户拖拽而产生滚动的（主要是判断 CollectionView 是用户拖拽而滚动的，还是点击 TableView 而滚动的），如果二者都成立，那么 TableView 的选中行就是 CollectionView 的当前 section。
* 2.在 CollectionView 分区标题展示结束里面，判断当前 CollectionView 滚动的方向向下， CollectionView 是用户拖拽而产生滚动的，如果二者都成立，那么 TableView 的选中行就是 CollectionView 的当前 section-1。

```swift
// 标记一下 CollectionView 的滚动方向，是向上还是向下
func scrollViewDidScroll(_ scrollView: UIScrollView) {
   if collectionView == scrollView {
       isScrollDown = lastOffsetY < scrollView.contentOffset.y
       lastOffsetY = scrollView.contentOffset.y
   }
}

// CollectionView 分区标题即将展示
func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
   // 当前 CollectionView 滚动的方向向上，CollectionView 是用户拖拽而产生滚动的（主要是判断 CollectionView 是用户拖拽而滚动的，还是点击 TableView 而滚动的）
   if !isScrollDown && collectionView.isDragging {
       selectRow(index: indexPath.section)
   }
}
    
// CollectionView 分区标题展示结束
func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
   // 当前 CollectionView 滚动的方向向下，CollectionView 是用户拖拽而产生滚动的（主要是判断 CollectionView 是用户拖拽而滚动的，还是点击 TableView 而滚动的）
   if isScrollDown && collectionView.isDragging {
       selectRow(index: indexPath.section + 1)
   }
}
    
// 当拖动 CollectionView 的时候，处理 TableView
private func selectRow(index : Int) {
   tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
}
    
```
TableView 与 CollectionView 之间的联动就这么实现了，是不是也很简单。

![TableView 与 CollectionView 之间的联动](http://upload-images.jianshu.io/upload_images/1321491-3e4c91db3ab471cf.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 最后

由于笔者水平有限，文中如果有错误的地方，或者有更好的方法，还望大神指出。
附上本文的所有 demo 下载链接，[【GitHub - Swift 版】](https://github.com/leejayID/Linkage-Swift)、[【GitHub - OC 版】](https://github.com/leejayID/Linkage)，配合 demo 一起看文章，效果会更佳。
如果你看完后觉得对你有所帮助，还望在 GitHub 上点个 star。赠人玫瑰，手有余香。

