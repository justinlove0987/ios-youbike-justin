//
//  YoubikeManager.swift
//  Youbike
//
//  Created by 曾柏瑒 on 2022/1/11.
//

import UIKit
import CoreData

struct YoubikeManager {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func performRequest(with urlString: String, completion: @escaping (Result<[YoubikeModel], Error>) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    completion(.failure(error!))
                }
                
                if let safeData = data {
                    if let youbikeModels = self.parseJSON(safeData) {
                        completion(.success(youbikeModels))
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    func parseJSON(_ youbikeData: Data) -> [YoubikeModel]? {
        
        let decoder = JSONDecoder()
        
        do {
            let youbikeAPIDatas = try decoder.decode([YoubikeData].self, from: youbikeData)
            
            let youbikeModels: [YoubikeModel] = youbikeAPIDatas.compactMap { youbikeAPIData in
                
                // create youbike model
                let id = youbikeAPIData.sno
                let chineseName = youbikeAPIData.sna
                let totalParkingSpace = youbikeAPIData.tot
                let currentBikeNumber = youbikeAPIData.sbi
                let chineseArea = youbikeAPIData.sarea
                let chineseAddress = youbikeAPIData.ar
                let latitude = youbikeAPIData.lat
                let longtitude = youbikeAPIData.lng
                
                
                return YoubikeModel(id : id,
                                    chineseName: chineseName,
                                    totalParkingSpace: totalParkingSpace,
                                    currentBikeNumber: currentBikeNumber,
                                    chineseArea: chineseArea,
                                    chineseAddress: chineseAddress,
                                    latitude: latitude,
                                    longtitude: longtitude
                )
            }
            
            return youbikeModels
            
        } catch {
            print("Failed to parseJson \(error.localizedDescription)")
            return nil
        }
    }
    
//    func deleteAllCoreDatas() {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "YoubikeCoreData")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try context.execute(deleteRequest)
//        } catch {
//            print("DEBUG: Failed to get data from coredata \(error.localizedDescription)")
//        }
//    }
    
    
}

