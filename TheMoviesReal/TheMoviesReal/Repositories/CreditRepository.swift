//
//  CreditRepository.swift
//  TheMoviesReal
//
//  Created by Trịnh Giang Đông on 7/31/18.
//  Copyright © 2018 Hai. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

protocol CreditRepository {
    func getCredit(input: MovieCreditRequest) -> Observable<MovieCreditResponse>
    func getPersonCredit(input: PersonCreditRequest) -> Observable<PersonCreditResponse>
}

class CreditRepositoryImp: CreditRepository {
    private var api: APIService!
    
    required init(api: APIService) {
        self.api = api
    }
    
    func getCredit(input: MovieCreditRequest) -> Observable<MovieCreditResponse> {
        return api.request(input: input)
            .map { (response: MovieCreditResponse) in
                return response
            }
    }
    
    func getPersonCredit(input: PersonCreditRequest) -> Observable<PersonCreditResponse> {
        return api.request(input: input)
            .map { (response: PersonCreditResponse) in
                return response
        }
    }
}
