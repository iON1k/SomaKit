//
//  SomaContentViewController.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class SomaContentViewController<TViewModel: ContentViewModelType>: SomaViewController<TViewModel> {
    open var _contentView: UIView? {
        return nil
    }

    open var _errorView: UIView? {
        return nil
    }

    open var _emptyView: UIView? {
        return nil
    }

    open var _activityIndicator: ActivityIndicator? {
        return nil
    }

    open override func _onBindUI(viewModel: TViewModel) {
        super._onBindUI(viewModel: viewModel)

        viewModel.contentState.bindNext({ [weak self] (contentState) in
            self?.contentStateDidChanged(contentState: contentState)
        })
        .dispose(whenDeallocated: self)
    }

    private func contentStateDidChanged(contentState: ContentState) {
        _contentView?.isHidden = !_isContentViewVisible(contentState: contentState)
        _errorView?.isHidden = !_isErrorViewVisible(contentState: contentState)
        _emptyView?.isHidden = !_isEmptyViewVisible(contentState: contentState)
        _activityIndicator?.setActive(active: _isActivityIndicatorActive(contentState: contentState))

        _onContentStateChanged(contentState: contentState)
    }

    open func _onContentStateChanged(contentState: ContentState) {
        //Nothing
    }

    open func _isContentViewVisible(contentState: ContentState) -> Bool {
        switch contentState {
        case .normal(let isEmpty):
            return !isEmpty
        default:
            return false
        }
    }

    open func _isEmptyViewVisible(contentState: ContentState) -> Bool {
        switch contentState {
        case .normal(let isEmpty):
            return isEmpty
        default:
            return false
        }
    }

    open func _isErrorViewVisible(contentState: ContentState) -> Bool {
        switch contentState {
        case .error:
            return true
        default:
            return false
        }
    }

    open func _isActivityIndicatorActive(contentState: ContentState) -> Bool {
        if case .loading = contentState {
            return true
        }

        return false
    }
}
