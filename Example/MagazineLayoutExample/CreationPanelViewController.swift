// Created by bryankeller on 11/30/18.
// Copyright © 2018 Airbnb, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

final class CreationPanelViewController: UIViewController {

  // MARK: Lifecycle

  init(
    dataSourceCountsProvider: DataSourceCountsProvider,
    initialState: ItemCreationPanelViewState?)
  {
    itemCreationPanelView = ItemCreationPanelView(
      dataSourceCountsProvider: dataSourceCountsProvider)

    if let initialState = initialState {
      itemCreationPanelView.state = initialState
    }

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  /// A closure that is retained to handle the done button being tapped
  var doneButtonTapHandler: ((ItemCreationPanelViewState) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    navigationItem.title = "Create Item"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(doneButtonTapped))

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelTapped))

    view.addSubview(itemCreationPanelView)

    itemCreationPanelView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      itemCreationPanelView.leadingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      itemCreationPanelView.trailingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      itemCreationPanelView.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor,
        constant: 24),
      itemCreationPanelView.bottomAnchor.constraint(
        lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
      ])
  }

  // MARK: Private

  private let itemCreationPanelView: ItemCreationPanelView

  @objc
  private func cancelTapped() {
    dismiss(animated: true, completion: nil)
  }

  @objc
  private func doneButtonTapped() {
    doneButtonTapHandler?(itemCreationPanelView.state)
  }

}
