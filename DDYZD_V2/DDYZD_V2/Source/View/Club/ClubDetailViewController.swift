//
//  ClubDetailViewController.swift
//  DDYZD_V2
//
//  Created by 김수완 on 2021/02/04.
//

import UIKit

import RxCocoa
import RxSwift

class ClubDetailViewController: UIViewController {

    public var clubID = 0
    
    @IBOutlet weak var feedTable: UITableView!
    @IBOutlet weak var clubBackImage: UIImageView!
    @IBOutlet weak var clubProfileImgae: UIImageView!
    @IBOutlet weak var clubNameLabel: UILabel!
    
    private let viewModel = ClubDetailViewModel()
    private let disposeBag = DisposeBag()
    private var loadMore = false
    
    private let getFeed = PublishSubject<LoadFeedAction>()
    private let flagIt = PublishSubject<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bind()
        setTableView()
        registerCell()
        reloadFeeds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBar()
    }
    
    func bind() {
        viewModel.clubID = clubID
        let input = ClubDetailViewModel.input(getFeed: getFeed.asDriver(onErrorJustReturn: .reload), flagIt: flagIt.asDriver(onErrorJustReturn: -1))
        let output = viewModel.transform(input)
        
        output.feedList.bind(to: feedTable.rx.items) { _, row, item -> UITableViewCell in
            self.loadMore = false
            if item.media.isEmpty {
                let cell = self.feedTable.dequeueReusableCell(withIdentifier: "Feed") as! FeedTableViewCell
                
                cell.bind(item: item)
                cell.flagBtn.rx.tap.subscribe(onNext: {
                    self.flagIt.onNext(row)
                    output.flagItResult.subscribe(onNext: { err in
                        self.moveLogin(didJustBrowsingBtnTaped: nil, didSuccessLogin: nil)
                    })
                    .disposed(by: cell.disposeBag)
                }).disposed(by: cell.disposeBag)
                
                return cell
            } else {
                let cell = self.feedTable.dequeueReusableCell(withIdentifier: "FeedWithMedia") as! FeedWithMediaTableViewCell
                
                cell.bind(item: item)
                cell.flagBtn.rx.tap.subscribe(onNext: {
                    self.flagIt.onNext(row)
                    output.flagItResult.subscribe(onNext: { err in
                        self.moveLogin(didJustBrowsingBtnTaped: nil, didSuccessLogin: nil)
                    })
                    .disposed(by: cell.disposeBag)
                }).disposed(by: cell.disposeBag)
                
                return cell
            }
        }
        .disposed(by: disposeBag)
    }
    
    func reloadFeeds(){
        getFeed.onNext(.reload)
    }
    
    func loadMoreFeeds(){
        loadMore = true
        getFeed.onNext(.loadMore)
    }
    

}


// MARK:- UI
extension ClubDetailViewController {
    func setUI(){
        clubProfileImgae.circleImage()
        clubProfileImgae.layer.borderWidth = 1
        clubProfileImgae.layer.borderColor = #colorLiteral(red: 0.7685618401, green: 0.768670857, blue: 0.7685275674, alpha: 1)
    }
    
    func setNavigationBar(){
        navigationController?.navigationBar.standardAppearance.shadowColor = .gray
        navigationController?.navigationBar.standardAppearance.backgroundColor = .white
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.4811326265, green: 0.1003668979, blue: 0.812384963, alpha: 1)
    }
}


// MARK:- table view
extension ClubDetailViewController: UITableViewDelegate {
    
    func setTableView(){
        feedTable.separatorStyle = .none
        feedTable.allowsSelection = false
        feedTable.delegate = self
        initRefresh()
    }
    
    func registerCell() {
        let feedNib = UINib(nibName: "Feed", bundle: nil)
        feedTable.register(feedNib, forCellReuseIdentifier: "Feed")
        let feedWithMediadNib = UINib(nibName: "FeedWithMedia", bundle: nil)
        feedTable.register(feedWithMediadNib, forCellReuseIdentifier: "FeedWithMedia")
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? FeedTableViewCell {
            cell.disposeBag = DisposeBag()
            cell.flagBtn.isSelected = false
            cell.cellSuperView.layer.borderWidth = 0
        } else if let cell = cell as? FeedWithMediaTableViewCell {
            cell.disposeBag = DisposeBag()
            cell.flagBtn.isSelected = false
            cell.cellSuperView.layer.borderWidth = 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
                
        if offsetY > contentHeight - scrollView.frame.height{
            if !loadMore {
                loadMoreFeeds()
            }
        }
    }
    
    func initRefresh() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshFeed(refresh:)), for: .valueChanged)
        feedTable.refreshControl = refresh
    }
    
    @objc func refreshFeed(refresh: UIRefreshControl) {
        refresh.endRefreshing()
        reloadFeeds()
    }
}
