//
//  ListViewController.swift
//  iMobility Weather
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

import Strongify
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt
import RxOptional

final class ListViewController: UIViewController {
    
    typealias ViewModelType = ListViewModel
    
    private static let _cellIdentifier: String = "ListCellIdentifier"
    
    private let _viewModel: ViewModelType
    private var _disposeBag = DisposeBag()
    
    private lazy var _tableView: UITableView = self._createTableView()
    private lazy var _pullToRefresh: UIRefreshControl = self._createPullToRefresh()
    
    init(viewModel: ViewModelType) {
        self._viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._disposeBag = DisposeBag()
        
        self._setupUI()
        self._setupAutoLayout()
        
        self.rx.viewWillAppearObservable
            .take(1)
            .map({ (_) -> Void in
                return
            })
            .bind(to: self._viewModel.fetchAction)
            .disposed(by: self._disposeBag)
        
        self._pullToRefresh.rx.controlEvent(.valueChanged)
            .bind(to: self._viewModel.fetchAction)
            .disposed(by: self._disposeBag)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<ListSection>(
            configureCell: { [unowned self] (dataSource, tableView, indexPath, item) -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self)._cellIdentifier,
                                                               for: indexPath) as? ListCell
                    else {
                        fatalError("Couldn't create custom cell")
                }
                cell.configure(with: item.service)
                return cell
        })
        
        let data = self._viewModel.data
            .share(replay: 1,
                   scope: .forever)
        data
            .bind(to: self._tableView.rx.items(dataSource: dataSource))
            .disposed(by: self._disposeBag)
        if let backgroundView = self._tableView.backgroundView {
            data
                .map({ (data) -> CGFloat in
                    return data.isEmpty ? 1.0 : 0.0
                })
                .distinctUntilChanged()
                .bind(to: backgroundView.rx.alpha)
                .disposed(by: self._disposeBag)
        }
        data
            .filterEmpty()
            .delay(.seconds(0), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: strongify(weak: self,
                                         closure: { (self, _) in
                                            self._tableView.reloadData()
            }))
            .disposed(by: self._disposeBag)
        
        self._viewModel.error
            .subscribe(onNext: strongify(weak: self,
                                         closure: { (self, error) in
                                            self._showAlert(with: "Error",
                                                            message: error.localizedDescription)
            }))
            .disposed(by: self._disposeBag)
        
        self._viewModel.isLoading
            .bind(to: self._pullToRefresh.rx.isRefreshing)
            .disposed(by: self._disposeBag)
        
        self._tableView.rx.modelSelected(ViewModelType.ModelType.self)
            .subscribe(onNext: strongify(weak: self,
                                         closure: { (self, item) in
                                            self._didSelect(item: item)
            }))
            .disposed(by: self._disposeBag)
    }
    
}

extension ListViewController {
    
    private func _createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.register(ListCell.self,
                           forCellReuseIdentifier: type(of: self)._cellIdentifier)
        return tableView
    }
    
    private func _createPullToRefresh() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return refreshControl
    }
    
    private func _createEmptyBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No data"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leftAnchor.constraint(lessThanOrEqualTo: view.leftAnchor,
                                    constant: 10).isActive = true
        label.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor,
                                   constant: 10).isActive = true
        
        return view
    }
    
    // MARK: setup UI & autolayout
    private func _setupUI() {
        self.title = "Cities"
        
        self.view.backgroundColor = .backgroundColor
        
        self.view.addSubview(self._tableView)
        self._tableView.refreshControl = self._pullToRefresh
        self._tableView.backgroundView = self._createEmptyBackgroundView()
        self._tableView.tableFooterView = UIView()
        
        self._tableView.backgroundView?.alpha = 1
        self._tableView.rowHeight = UITableView.automaticDimension
        self._tableView.estimatedRowHeight = 100
    }
    
    private func _setupAutoLayout() {
        self._tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self._tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self._tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self._tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
}

extension ListViewController {
    
    private func _showAlert(with title: String,
                            message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .cancel,
                                                handler: nil))
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
    
}

extension ListViewController {
    
    private func _didSelect(item: ViewModelType.ModelType) {
        
    }
    
}
