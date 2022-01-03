//
//  ServiceLayer.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/20/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya
import Alamofire

class ServiceLayer<Target: BaseEndpoint> {
    
    // MARK: Properties
    
    private(set) var provider: MoyaProvider<Target>?
    
    // MARK: Init
    
    required init(endpointClosure: ((Target) -> Endpoint)? = nil, stubClosure: @escaping ((Target) -> StubBehavior) = MoyaProvider.neverStub) {
        
        let token = "\(OktaSessionManager.shared.accessToken)"
        let authPlugin = AccessTokenPlugin(tokenClosure: { return token })

        let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
            do {
               var request = try endpoint.urlRequest()
                // prevents a 304 Not Modified when the resonse on subsequent calls to the same endpoint has not changed
                // iOS throws the 304 by default; we're ignoring that behavior here for better debugging of service calls
                request.cachePolicy = .reloadIgnoringCacheData
                done(.success(request))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        }

        if let endpointClosure = endpointClosure {
            // endpointClosure used in Unit Tests to mock empty responses and 500 errors
            self.provider = MoyaProvider<Target>(endpointClosure: endpointClosure, stubClosure: stubClosure, plugins: [authPlugin])
        } else {
            self.provider = MoyaProvider<Target>(requestClosure: requestClosure, stubClosure: stubClosure, plugins: [authPlugin])
        }
    }
    
    // MARK: GET API calls
    
    func fetch<Model: Codable>(_ endpoint: Target, cleanPersist: Bool = false, completion: @escaping (ServiceResult<[Model]>) -> Void) {
        provider?.request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    // First do a parsing pass so that we can capture/report errors
                    let parsedFailables = try filteredResponse.map([FailableDecodable<Model>].self, atKeyPath: "data")
                    let decodingErrors = parsedFailables.compactMap { $0.decodingError }
                    DecodingErrors.handleDecodingErrors(decodingErrors, endpoint: endpoint.path, path: "data")
                    let parsedData = parsedFailables.compactMap { $0.base }
                    if cleanPersist {
                        endpoint.cleanPersist?(parsedData)
                    } else {
                        endpoint.persist?(parsedData)
                    }
                    completion(.success(parsedData))
                } catch let error {
                    let error = "error mapping data: \(error)"
                    log(error: error)
                    completion(.failure(error))
                }
            case let .failure(error):
                let error = "failure fetching data: \(error)"
                log(error: error)
                completion(.failure(error))
            }
        }
    }
    
    func fetch<Model: Codable>(_ endpoint: Target, completion: @escaping (ServiceResult<Model>) -> Void) {
        provider?.request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let parsedData = try filteredResponse.map(Model.self, atKeyPath: "data")
                    endpoint.persist?([parsedData])
                    completion(.success(parsedData))
                } catch let error {
                    let error = "error mapping data: \(error)"
                    log(error: error)
                    completion(.failure(error))
                }
            case let .failure(error):
                let error = "failure fetching data: \(error)"
                log(error: error)
                completion(.failure(error))
            }
        }
    }
    
    // MARK: POST API calls
    
    func create(_ endpoint: Target, completion: ((ServiceResult<Any>) -> Void)? = nil) {
        provider?.request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    completion?(.success(filteredResponse))
                } catch let error {
                    let error = "error sending data: \(error)"
                    log(error: error)
                    completion?(.failure(error))
                }
            case let .failure(error):
                let error = "failure fetching data: \(error)"
                log(error: error)
                completion?(.failure(error))
            }
        }
    }
    
    func sendData(_ endpoint: Target, completion: ((ServiceResult<Any>) -> Void)? = nil) {
        provider?.request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    completion?(.success(filteredResponse))
                } catch let error {
                    let error = "error sending data: \(error)"
                    log(error: error)
                    completion?(.failure(error))
                }
            case let .failure(error):
                let error = "failure fetching data: \(error)"
                log(error: error)
                completion?(.failure(error))
            }
        }
    }

}

// MARK: Service Result

enum ServiceResult<Result> {
    case success(Result)
    case failure(String)
}
