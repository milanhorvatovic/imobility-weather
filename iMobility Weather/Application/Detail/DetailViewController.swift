//
//  DetailViewController.swift
//  iMobility Weather
//
//  Created by Milan Horvatovic on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import Strongify
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt
import RxOptional

final class DetailViewController: UIViewController {
    
    typealias ViewModelType = DetailViewModel
    
    private static let _cellIdentifier: String = "DetailCellIdentifier"
    
    private static let _dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let _viewModel: ViewModelType
    private var _disposeBag = DisposeBag()
    
    private lazy var _headerView: DetailHeaderView = self._createHeaderView()
    private lazy var _separatorHorizontalView: UIView = self._createSeparator()
    private lazy var _separatorVerticalView: UIView = self._createSeparator()
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
        
        self._viewModel.weatherData
            .subscribe(onNext: strongify(weak: self,
                                         closure: { (self, weather) in
                                            self.title = weather.service?.name
                                            self._headerView.configure(with: weather)
            }))
            .disposed(by: self._disposeBag)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<DetailListSection>(
            configureCell: { [unowned self] (dataSource, tableView, indexPath, item) -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self)._cellIdentifier,
                                                               for: indexPath) as? DetailCell
                    else {
                        fatalError("Couldn't create custom cell")
                }
                cell.configure(with: item)
                return cell
            },
            titleForHeaderInSection: { [unowned self] (dataSource, index) -> String? in
                guard let timeInterval = Double(dataSource[index].identity) else {
                    return nil
                }
                return type(of: self)._dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval * 86400.0))
        })
        
        let data = self._viewModel.forecastData
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
    }
    
}

extension DetailViewController {
    
    private func _createHeaderView() -> DetailHeaderView {
        let view = DetailHeaderView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func _createSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func _createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.register(DetailCell.self,
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
        self.view.backgroundColor = .backgroundColor
        
        self.view.addSubview(self._tableView)
        
        self._headerView.addSubview(self._separatorVerticalView)
        self._headerView.addSubview(self._separatorHorizontalView)
        
        self._tableView.refreshControl = self._pullToRefresh
        self._tableView.tableHeaderView = self._headerView
        self._tableView.backgroundView = self._createEmptyBackgroundView()
        self._tableView.tableFooterView = UIView()
        
        self._tableView.backgroundView?.alpha = 1
        self._tableView.rowHeight = UITableView.automaticDimension
        self._tableView.estimatedRowHeight = 100
    }
    
    private func _setupAutoLayout() {
        if #available(iOS 11.0, *) {
            let viewGuide = self.view.safeAreaLayoutGuide
            self._tableView.leftAnchor.constraint(equalTo: viewGuide.leftAnchor).isActive = true
            self._tableView.rightAnchor.constraint(equalTo: viewGuide.rightAnchor).isActive = true
            self._tableView.topAnchor.constraint(equalTo: viewGuide.topAnchor).isActive = true
            self._tableView.bottomAnchor.constraint(equalTo: viewGuide.bottomAnchor).isActive = true
        }
        else {
            self._tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self._tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            self._tableView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor).isActive = true
            self._tableView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.bottomAnchor).isActive = true
        }
        
        self._headerView.leftAnchor.constraint(equalTo: self._tableView.leftAnchor).isActive = true
        self._headerView.rightAnchor.constraint(equalTo: self._tableView.rightAnchor).isActive = true
        self._headerView.topAnchor.constraint(equalTo: self._tableView.topAnchor).isActive = true
        self._headerView.widthAnchor.constraint(equalTo: self._tableView.widthAnchor).isActive = true
        
        self._separatorVerticalView.centerXAnchor.constraint(equalTo: self._headerView.centerXAnchor).isActive = true
        self._separatorVerticalView.widthAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        self._separatorVerticalView.topAnchor.constraint(equalTo: self._headerView.topAnchor).isActive = true
        self._separatorVerticalView.bottomAnchor.constraint(equalTo: self._headerView.bottomAnchor).isActive = true
        
        self._separatorHorizontalView.leftAnchor.constraint(equalTo: self._headerView.leftAnchor).isActive = true
        self._separatorHorizontalView.rightAnchor.constraint(equalTo: self._headerView.rightAnchor).isActive = true
        self._separatorHorizontalView.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        self._separatorHorizontalView.bottomAnchor.constraint(equalTo: self._headerView.bottomAnchor).isActive = true
        
    }
    
}

extension DetailViewController {
    
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
