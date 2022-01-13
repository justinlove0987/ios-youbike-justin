//
//  MainController.swift
//  Youbike
//
//  Created by 曾柏瑒 on 2022/1/11.
//

import UIKit
import CoreLocation
import CoreData

private let identifier = "Cell"

class MainController: UIViewController {
    
    // MARK: - Properties
    
    private var youbikeManager = YoubikeManager()
    private var youbikeModels = [YoubikeModel]()
    
    private var filterYoubikeModels: [YoubikeModel] = [YoubikeModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var youbikeCoreDatas = [YoubikeCoreData]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let refreshControl = UIRefreshControl()
    
    private let locationManager = CLLocationManager()
    
    private var userLocation: CLLocation?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        return table
    }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(handlePullRefresh), for: .valueChanged)
        
        loadYoubikeAPIDatas()
        configureiUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // when aligns out info.plist key
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    
    // MARK: - API
    
    func loadYoubikeAPIDatas() {
        let urlString = "https://tcgbusfs.blob.core.windows.net/dotapp/youbike/v2/youbike_immediate.json"
        youbikeManager.performRequest(with: urlString) { result in
            switch result {
            case .success(let youbikes):
                self.youbikeModels = youbikes
                
                self.updateYoubikeCoreDatas(youbikeModels: youbikes)
                
                self.youbikeModels = self.sortYoubikeModelByUserDistance(youbikeModels: self.youbikeModels)
                
                self.filterYoubikeModels = self.youbikeModels
                
            case .failure(let error):
                
                self.loadYoubikeCoreDatas()
                
                print("DEBUG: Failed to fetch youbike datas \(error)")
            }
        }
    }
    
    // MARK: - CoreData
    
    func updateYoubikeCoreDatas(youbikeModels: [YoubikeModel]){
        
        let request: NSFetchRequest<YoubikeCoreData> = YoubikeCoreData.fetchRequest()
        
        do{
            youbikeCoreDatas =  try context.fetch(request)
        } catch {
            print("Error fetching Data from context \(error)")
        }
        
        print("DEBUG: count current youbike coredata numbers \(youbikeCoreDatas.count)")
        
        // update Core Data
        for (youbikeModel) in youbikeModels {
            if youbikeCoreDatas.isEmpty {
                createCoreData(youbikeModel: youbikeModel)
            } else {
                updateCoreData(youbikeCoreDatas: youbikeCoreDatas, youbikeModel: youbikeModel)
            }
        }

        saveYoubikeCoreDatas()

    }
    
    func createCoreData(youbikeModel: YoubikeModel) {
        
        let newYoubikeCoreData = YoubikeCoreData(context: context)
        newYoubikeCoreData.sno = youbikeModel.id
        newYoubikeCoreData.sna = youbikeModel.chineseName
        newYoubikeCoreData.tot = Int16(youbikeModel.totalParkingSpace)
        newYoubikeCoreData.sbi = Int16(youbikeModel.currentBikeNumber)
        newYoubikeCoreData.sarea = youbikeModel.chineseArea
        newYoubikeCoreData.ar = youbikeModel.chineseAddress
        newYoubikeCoreData.lat = youbikeModel.latitude
        newYoubikeCoreData.lng = youbikeModel.longtitude
        
    }
    
    func updateCoreData(youbikeCoreDatas: [YoubikeCoreData], youbikeModel: YoubikeModel) {
        
        var isNew = true
        
        for (index, _) in youbikeCoreDatas.enumerated() {
            if youbikeCoreDatas[index].sno == youbikeModel.id {
                youbikeCoreDatas[index].sno = youbikeModel.id
                youbikeCoreDatas[index].sna = youbikeModel.chineseName
                youbikeCoreDatas[index].tot = Int16(youbikeModel.totalParkingSpace)
                youbikeCoreDatas[index].sbi = Int16(youbikeModel.currentBikeNumber)
                youbikeCoreDatas[index].sarea = youbikeModel.chineseArea
                youbikeCoreDatas[index].ar = youbikeModel.chineseAddress
                youbikeCoreDatas[index].lat = youbikeModel.latitude
                youbikeCoreDatas[index].lng = youbikeModel.longtitude
                isNew = false
                return
            }
        }
        
        // if we don't find any of them in coredatabase, we create one.
        if isNew {
            createCoreData(youbikeModel: youbikeModel)
        }
        
    }
    
    func loadYoubikeCoreDatas() {
        
        let request: NSFetchRequest<YoubikeCoreData> = YoubikeCoreData.fetchRequest()
        
        do{
            youbikeCoreDatas =  try context.fetch(request)
        } catch {
            print("Error fetching Data from context \(error)")
        }
        
        youbikeModels = youbikeCoreDatas.compactMap({ youbikeCoreData in
            guard let id = youbikeCoreData.sno,
                  let chineseName = youbikeCoreData.sna,
                  let chineseArea = youbikeCoreData.sarea,
                  let chineseAddress = youbikeCoreData.ar else {
                      return nil
                  }
            let totalParkingSpace = youbikeCoreData.tot
            let currentBikeNumber = youbikeCoreData.sbi
            let latitude = youbikeCoreData.lat
            let longtitude = youbikeCoreData.lng
            
            return YoubikeModel(id: id,
                                chineseName: chineseName,
                                totalParkingSpace: Int(totalParkingSpace),
                                currentBikeNumber: Int(currentBikeNumber),
                                chineseArea: chineseArea,
                                chineseAddress: chineseAddress,
                                latitude: latitude,
                                longtitude: longtitude)
        })
        
        filterYoubikeModels = youbikeModels
        
    }
    
    func saveYoubikeCoreDatas() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    // MARK: - Actions
    
    @objc func handlePullRefresh() {
        loadYoubikeAPIDatas()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Helpers
    
    func configureiUI() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        
        navigationItem.title = "列表頁"
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
    
    func sortYoubikeModelByUserDistance(youbikeModels: [YoubikeModel]) -> [YoubikeModel] {
        let youbikeModels = youbikeModels.sorted { this, that in
            if let userLatitude = self.userLocation?.coordinate.latitude,
               let userLongtitude = self.userLocation?.coordinate.longitude {
                
                let thisHypotf = calculateHypotf(x1: userLatitude, x2: this.latitude,
                                                      y1: userLongtitude, y2: this.longtitude)
                let thatHypotf = calculateHypotf(x1: userLatitude, x2: that.latitude,
                                                      y1: userLongtitude, y2: that.longtitude)
                
                return thisHypotf < thatHypotf
            }
            return true
        }
        
        return youbikeModels
    }
    
    func calculateHypotf(x1: Double, x2: Double, y1: Double, y2: Double) -> Float {
        let latitudeLength = (x1 - x2)
        let longtitudeLength = (y1 - y2)
        let hypotf = hypotf(Float(latitudeLength), Float(longtitudeLength))
        return hypotf
    }
    
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterYoubikeModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        let chineseName = filterYoubikeModels[indexPath.row].chineseName
        let totalParkingSpace = filterYoubikeModels[indexPath.row].totalParkingSpace
        let currentBikeNumber = filterYoubikeModels[indexPath.row].currentBikeNumber
        
        cell.textLabel?.text = "場站中文名稱: \(chineseName)\n場站總停車格: \(totalParkingSpace)\n場站目前車輛數量: \(currentBikeNumber)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = InformationController()
        vc.youbikeModel = self.filterYoubikeModels[indexPath.row]
        vc.userLocation = userLocation
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

// MARK: - CLLocationManagerDelegate

extension MainController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location
            // test location
            // userLocation = CLLocation(latitude: 25.02605, longitude: 121.5436)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension MainController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        self.filterYoubikeModels = self.youbikeModels.filter { youbikeModel in
            return youbikeModel.chineseName.contains(text)
        }
        
        if text == "" {
            self.filterYoubikeModels = self.youbikeModels
        }
        
    }
}




