//
//  URLRequest+Extension.swift
//  NewsApp
//
//  Created by Nathaniel Andrian on 15/12/22.
//

import Foundation
import RxSwift
import RxCocoa

struct Resource<T: Decodable> {
    let url: URL
}

struct FailDecodeData: Error {
    
}

extension URLRequest {
    
    // with observable
    static func load<T>(resource: Resource<T>) -> Observable<T?> {
        
        return Observable.from([resource.url])
            .flatMap { urlreq -> Observable<Data> in
                let request = URLRequest(url: urlreq)
                return URLSession.shared.rx.data(request: request)
            }.map { data -> T? in
                return try JSONDecoder().decode(T.self, from: data)
            }
            .do(onDispose: {
                print("cancel task")
            })
                .asObservable()
                }
    
    static func loadData<T>(resource: Resource<T>) -> Single<T> {
        return Single<T>.create { single in
            let request = URLRequest(url: resource.url)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    
                    single(.failure(error))
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    single(.failure(FailDecodeData.self as! Error))
                    return
                    
                }
                if let data = data {
                    let result = try? JSONDecoder().decode(T.self, from: data)
                    single(.success(result!))
                }
                
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
            
            
        }
    }
    
}
