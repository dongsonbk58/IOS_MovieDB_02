//
//  ViewModelLoadMore.swift
//  TheMoviesReal
//
//  Created by Trịnh Giang Đông on 7/26/18.
//  Copyright © 2018 Hai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ViewModelType {
    func setupLoadMorePaging<T>(loadTrigger: Driver<Void>,
                                getItems: @escaping () -> Observable<PagingInfo<T>>,
                                refreshTrigger: Driver<Void>,
                                refreshItems: @escaping () -> Observable<PagingInfo<T>>,
                                loadMoreTrigger: Driver<Void>,
                                loadMoreItems: @escaping (Int) -> Observable<PagingInfo<T>>)
        -> (page: BehaviorRelay<PagingInfo<T>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        loading: Driver<Bool>,
        refreshing: Driver<Bool>,
        loadingMore: Driver<Bool>) {
            
            let pageSubject = BehaviorRelay<PagingInfo<T>>(value: PagingInfo<T>(page: 1, items: []))
            let errorTracker = ErrorTracker()
            let loadingActivityIndicator = ActivityIndicator()
            let refreshingActivityIndicator = ActivityIndicator()
            let loadingMoreActivityIndicator = ActivityIndicator()
            
            let loading = loadingActivityIndicator.asDriver()
            let refreshing = refreshingActivityIndicator.asDriver()
            let loadingMore = loadingMoreActivityIndicator.asDriver()
            
            let loadingOrLoadingMore = Driver.merge(loading, refreshing, loadingMore)
                .startWith(false)
            
            let loadItems = loadTrigger
                .withLatestFrom(loadingOrLoadingMore)
                .filter { !$0 }
                .flatMapLatest { _ in
                    getItems()
                        .trackError(errorTracker)
                        .trackActivity(loadingActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .do(onNext: { page in
                    pageSubject.accept(page)
                })
                .mapToVoid()
            
            let refreshItems = refreshTrigger
                .withLatestFrom(loadingOrLoadingMore)
                .filter { !$0 }
                .flatMapLatest { _ in
                    refreshItems()
                        .trackError(errorTracker)
                        .trackActivity(refreshingActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .do(onNext: { page in
                    pageSubject.accept(page)
                })
                .mapToVoid()
            
            let loadMoreItems = loadMoreTrigger
                .withLatestFrom(loadingOrLoadingMore)
                .filter { !$0 }
                .filter { _ in !pageSubject.value.items.isEmpty }
                .flatMapLatest { _ -> Driver<PagingInfo<T>> in
                    let page = pageSubject.value.page
                    return loadMoreItems(page + 1)
                        .trackError(errorTracker)
                        .trackActivity(loadingMoreActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .filter { !$0.items.isEmpty }
                .do(onNext: { page in
                    let currentPage = pageSubject.value
                    let items: [T] = currentPage.items + page.items
                    let newPage = PagingInfo<T>(page: page.page, items: items)
                    pageSubject.accept(newPage)
                })
                .mapToVoid()
            
            let fetchItems = Driver.merge(loadItems, refreshItems, loadMoreItems)
            return (pageSubject,
                    fetchItems,
                    errorTracker.asDriver(),
                    loading,
                    refreshing,
                    loadingMore)
    }
}

extension ViewModelType {
    func setupLoadMorePagingWithParam<T, U>(loadTrigger: Driver<U>,
                                            getItems: @escaping (U) -> Observable<PagingInfo<T>>,
                                            refreshTrigger: Driver<U>,
                                            refreshItems: @escaping (U) -> Observable<PagingInfo<T>>,
                                            loadMoreTrigger: Driver<U>,
                                            loadMoreItems: @escaping (U, Int) -> Observable<PagingInfo<T>>)
        -> (page: BehaviorRelay<PagingInfo<T>>,
        fetchItems: Driver<Void>,
        error: Driver<Error>,
        loading: Driver<Bool>,
        refreshing: Driver<Bool>,
        loadingMore: Driver<Bool>) {
            
            let pageSubject = BehaviorRelay<PagingInfo<T>>(value: PagingInfo<T>(page: 1, items: []))
            let errorTracker = ErrorTracker()
            let loadingActivityIndicator = ActivityIndicator()
            let refreshingActivityIndicator = ActivityIndicator()
            let loadingMoreActivityIndicator = ActivityIndicator()
            
            let loading = loadingActivityIndicator.asDriver()
            let refreshing = refreshingActivityIndicator.asDriver()
            let loadingMore = loadingMoreActivityIndicator.asDriver()
            
            let loadingOrLoadingMore = Driver.merge(loading, refreshing, loadingMore)
                .startWith(false)
            
            let loadItems = loadTrigger
                .withLatestFrom(loadingOrLoadingMore) {
                    (arg: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.arg }
                .flatMapLatest { arg in
                    getItems(arg)
                        .trackError(errorTracker)
                        .trackActivity(loadingActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .do(onNext: { page in
                    pageSubject.accept(page)
                })
                .mapToVoid()
            
            let refreshItems = refreshTrigger
                .withLatestFrom(loadingOrLoadingMore) {
                    (arg: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.arg }
                .flatMapLatest { arg in
                    refreshItems(arg)
                        .trackError(errorTracker)
                        .trackActivity(refreshingActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .do(onNext: { page in
                    pageSubject.accept(page)
                })
                .mapToVoid()
            
            let loadMoreItems = loadMoreTrigger
                .withLatestFrom(loadingOrLoadingMore) {
                    (arg: $0, loading: $1)
                }
                .filter { !$0.loading }
                .map { $0.arg }
                .filter { _ in !pageSubject.value.items.isEmpty }
                .flatMapLatest { arg -> Driver<PagingInfo<T>> in
                    let page = pageSubject.value.page
                    return loadMoreItems(arg, page + 1)
                        .trackError(errorTracker)
                        .trackActivity(loadingMoreActivityIndicator)
                        .asDriverOnErrorJustComplete()
                }
                .filter { !$0.items.isEmpty }
                .do(onNext: { page in
                    let currentPage = pageSubject.value
                    let items: [T] = currentPage.items + page.items
                    let newPage = PagingInfo<T>(page: page.page, items: items)
                    pageSubject.accept(newPage)
                })
                .mapToVoid()
            
            let fetchItems = Driver.merge(loadItems, refreshItems, loadMoreItems)
            return (pageSubject,
                    fetchItems,
                    errorTracker.asDriver(),
                    loading,
                    refreshing,
                    loadingMore)
    }
}

