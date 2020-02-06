//
//  VTClient.swift
//  VirtualTourist_YY
//
//  Created by MacAir11 on 2019/12/20.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

class VTClient {
    static let apiKey = "675c49351e5271139edb5841017f10f2"
    
    enum EndPoints {
        
        static let base = "https://api.flickr.com/services/rest?method=flickr.photos.search"
        static let extras = "&extras=url_m"
        static let safe_search = "&safe_search=1"
        static let nojsoncallback = "&nojsoncallback=1"
        static let format = "&format=json"
        static let per_page = "&per_page=10"
        
        static let SEARCH_WIDTH = 1.0
        static let SEARCH_HEIGHT = 1.0
        static let SEARCH_LAT = (-100.0, 100.0)
        static let SEARCH_LONG = (-180.0, 180.0)
        
        case images(Double, Double)
        case imagesWithPageNumber(Double, Double, Int)
        
        var stringValue: String {
            switch self {
            case .images(let lat, let lng):
                return EndPoints.base + EndPoints.extras + EndPoints.safe_search + EndPoints.nojsoncallback + EndPoints.format + EndPoints.per_page + "&api_key=\(VTClient.apiKey)" + "&lat=\(lat)&lon=\(lng)"
            case .imagesWithPageNumber(let lat, let lon, let pageNumber):
                return EndPoints.base + EndPoints.extras + EndPoints.safe_search + EndPoints.nojsoncallback + EndPoints.format + EndPoints.per_page + "&api_key=\(VTClient.apiKey)" + "&page=\(pageNumber)" + "&bbox=" + bboxString(latitude: lat, longitude: lon)
            }
        }
        
        func bboxString(latitude: Double, longitude: Double)-> String{
            
            let minLat = max(latitude - EndPoints.SEARCH_HEIGHT, EndPoints.SEARCH_LAT.0)
            let maxLat = min(latitude + EndPoints.SEARCH_HEIGHT, EndPoints.SEARCH_LAT.1)
            let minLong = max(longitude - EndPoints.SEARCH_WIDTH, EndPoints.SEARCH_LONG.0)
            let maxLong = min(longitude + EndPoints.SEARCH_WIDTH, EndPoints.SEARCH_LONG.1)
            
            return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getURLForLocation(latitude: Double, longitude: Double, numOfPage: Int, completion: @escaping([URL]?, Error?, String?)-> ()){
        
        let request = URLRequest(url: EndPoints.imagesWithPageNumber(latitude, longitude, numOfPage).url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else{
                completion(nil, error, nil)
                return
            }
            
            guard let data = data else{
                completion(nil, nil, "No Data Returned")
                return
            }
            
            guard let output = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else{
                completion(nil, nil, "JSON Parsing Failed")
                return
            }
            
            guard let stat = output["stat"] as? String, stat == "ok" else{
                completion(nil,nil, "Flickr API returned Error")
                return
            }
            
            guard let photosResult = output["photos"] as? [String: Any] else{
                completion(nil, nil, "Cannot find key (photos) in \(output)")
                return
            }
            
            guard let photosArray = photosResult["photo"] as? [[String: Any]] else{
                completion(nil, nil, "Cannot find key (photo) in \(photosResult)")
                return
            }
            
            let PhotosURLs = photosArray.compactMap {photosResult -> URL? in
                guard let url = photosResult["url_m"] as? String else{
                    return nil
                }
                
                return URL(string: url)
            }
            
            completion(PhotosURLs,nil,nil)
            
        }
        task.resume()
    }
}
