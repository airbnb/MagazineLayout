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

import MagazineLayout
import UIKit

// MARK: - ItemCreationPanelView

final class ItemCreationPanelView: UIView {

  // MARK: Lifecycle

  init(dataSourceCountsProvider: DataSourceCountsProvider) {
    self.dataSourceCountsProvider = dataSourceCountsProvider

    sectionIndexLabel = UILabel(frame: .zero)
    sectionIndexStepper = UIStepper(frame: .zero)
    itemIndexLabel = UILabel(frame: .zero)
    itemIndexStepper = UIStepper(frame: .zero)
    widthModeLabel = UILabel(frame: .zero)
    widthModePicker = UIPickerView(frame: .zero)
    heightModeLabel = UILabel(frame: .zero)
    heightModePicker = UIPickerView(frame: .zero)
    textFieldLabel = UILabel(frame: .zero)
    textField = UITextField(frame: .zero)
    colorLabel = UILabel(frame: .zero)
    colorSegmentedControl = UISegmentedControl(frame: .zero)

    super.init(frame: .zero)

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    addGestureRecognizer(tapGestureRecognizer)

    setUpViews()
    setUpConstraints()
    updateAndValidateUIState()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  var state: ItemCreationPanelViewState {
    get {
      let widthMode: MagazineLayoutItemWidthMode
      switch widthModePicker.selectedRow(inComponent: 0) {
      case 0: widthMode = .fullWidth(respectsHorizontalInsets: true)
      case 1: widthMode = .fullWidth(respectsHorizontalInsets: false)
      case 2: widthMode = .halfWidth
      case 3: widthMode = .thirdWidth
      case 4: widthMode = .fourthWidth
      case 5: widthMode = .fifthWidth
      case 6: widthMode = .fractionalWidth(divisor: 10)
      default: widthMode = .fullWidth(respectsHorizontalInsets: true)
      }

      let heightMode: MagazineLayoutItemHeightMode
      switch heightModePicker.selectedRow(inComponent: 0) {
      case 0: heightMode = .static(height: 50)
      case 1: heightMode = .dynamic
      case 2: heightMode = .dynamicAndStretchToTallestItemInRow
      default: heightMode = .dynamic
      }

      let color = colors[colorSegmentedControl.selectedSegmentIndex]

      return ItemCreationPanelViewState(
        sectionIndex: Int(sectionIndexStepper.value),
        itemIndex: Int(itemIndexStepper.value),
        sizeMode: MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode),
        text: textField.text ?? "",
        color: color)
    }
    set {
      sectionIndexStepper.value = Double(newValue.sectionIndex)
      itemIndexStepper.value = Double(newValue.itemIndex)

      switch newValue.sizeMode.widthMode {
      case .fullWidth(respectsHorizontalInsets: true):
        widthModePicker.selectRow(0, inComponent: 0, animated: false)
      case .fullWidth(respectsHorizontalInsets: false):
        widthModePicker.selectRow(1, inComponent: 0, animated: false)
      case .fractionalWidth(divisor: 2):
        widthModePicker.selectRow(2, inComponent: 0, animated: false)
      case .fractionalWidth(divisor: 3):
        widthModePicker.selectRow(3, inComponent: 0, animated: false)
      case .fractionalWidth(divisor: 4):
        widthModePicker.selectRow(4, inComponent: 0, animated: false)
      case .fractionalWidth(divisor: 5):
        widthModePicker.selectRow(5, inComponent: 0, animated: false)
      case .fractionalWidth(divisor: 10):
        widthModePicker.selectRow(10, inComponent: 0, animated: false)
      default: break
      }

      switch newValue.sizeMode.heightMode {
      case .static:
        heightModePicker.selectRow(0, inComponent: 0, animated: false)
      case .dynamic:
        heightModePicker.selectRow(1, inComponent: 0, animated: false)
      case .dynamicAndStretchToTallestItemInRow:
        heightModePicker.selectRow(2, inComponent: 0, animated: false)
      }

      textField.text = newValue.text

      colorSegmentedControl.selectedSegmentIndex = colors.firstIndex(of: newValue.color) ?? 0

      updateAndValidateUIState()
    }
  }


  // MARK: Private

  private let dataSourceCountsProvider: DataSourceCountsProvider

  private let sectionIndexLabel: UILabel
  private let sectionIndexStepper: UIStepper
  private let itemIndexLabel: UILabel
  private let itemIndexStepper: UIStepper
  private let widthModeLabel: UILabel
  private let widthModePicker: UIPickerView
  private let heightModeLabel: UILabel
  private let heightModePicker: UIPickerView
  private let textFieldLabel: UILabel
  private let textField: UITextField
  private let colorLabel: UILabel
  private let colorSegmentedControl: UISegmentedControl

  private let colors = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
  ]

  private func setUpViews() {
    addSubview(sectionIndexLabel)
    sectionIndexStepper.value = 0
    sectionIndexStepper.tintColor = .gray
    sectionIndexStepper.addTarget(
      self,
      action: #selector(updateAndValidateUIState),
      for: .valueChanged)
    addSubview(sectionIndexStepper)

    addSubview(itemIndexLabel)
    itemIndexStepper.value = 0
    itemIndexStepper.tintColor = .gray
    itemIndexStepper.addTarget(
      self,
      action: #selector(updateAndValidateUIState),
      for: .valueChanged)
    addSubview(itemIndexStepper)

    textFieldLabel.text = "Item content"
    addSubview(textFieldLabel)
    textField.borderStyle = .roundedRect
    textField.delegate = self
    textField.text = "Item"
    addSubview(textField)

    colorLabel.text = "Color"
    addSubview(colorLabel)

    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
    let colorImages = colors.map { color in
      renderer.image { context in
        context.cgContext.setFillColor(color.cgColor)

        let rectangle = CGRect(x: 0, y: 0, width: 20, height: 20)
        context.cgContext.addRect(rectangle)
        context.cgContext.drawPath(using: .fill)
      }
    }
    for (index, colorImage) in colorImages.enumerated() {
      colorSegmentedControl.insertSegment(
        with: colorImage.withRenderingMode(.alwaysOriginal),
        at: index,
        animated: false)
    }
    colorSegmentedControl.selectedSegmentIndex = 0
    colorSegmentedControl.tintColor = .gray
    addSubview(colorSegmentedControl)

    widthModeLabel.text = "Width Mode"
    addSubview(widthModeLabel)
    widthModePicker.layer.borderWidth = 1
    widthModePicker.layer.borderColor = UIColor.lightGray.cgColor
    widthModePicker.dataSource = self
    widthModePicker.delegate = self
    widthModePicker.selectRow(2, inComponent: 0, animated: false)
    addSubview(widthModePicker)

    heightModeLabel.text = "Height Mode"
    addSubview(heightModeLabel)
    heightModePicker.layer.borderWidth = 1
    heightModePicker.layer.borderColor = UIColor.lightGray.cgColor
    heightModePicker.dataSource = self
    heightModePicker.delegate = self
    heightModePicker.selectRow(1, inComponent: 0, animated: false)
    addSubview(heightModePicker)
  }

  private func setUpConstraints() {
    subviews.forEach { view in
      view.translatesAutoresizingMaskIntoConstraints = false
    }

    textFieldLabel.setContentHuggingPriority(.required, for: .horizontal)

    NSLayoutConstraint.activate([
      sectionIndexLabel.leadingAnchor.constraint(
        equalTo: layoutMarginsGuide.leadingAnchor,
        constant: 24),
      sectionIndexLabel.centerYAnchor.constraint(equalTo: sectionIndexStepper.centerYAnchor),

      sectionIndexStepper.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      sectionIndexStepper.trailingAnchor.constraint(
        equalTo: layoutMarginsGuide.trailingAnchor,
        constant: -24),

      itemIndexLabel.leadingAnchor.constraint(equalTo: sectionIndexLabel.leadingAnchor),
      itemIndexLabel.centerYAnchor.constraint(equalTo: itemIndexStepper.centerYAnchor),

      itemIndexStepper.trailingAnchor.constraint(equalTo: sectionIndexStepper.trailingAnchor),
      itemIndexStepper.topAnchor.constraint(
        equalTo: sectionIndexStepper.bottomAnchor,
        constant: 12),

      textFieldLabel.leadingAnchor.constraint(equalTo: itemIndexLabel.leadingAnchor),
      textFieldLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor),

      textField.leadingAnchor.constraint(equalTo: textFieldLabel.trailingAnchor, constant: 12),
      textField.trailingAnchor.constraint(equalTo: itemIndexStepper.trailingAnchor),
      textField.topAnchor.constraint(equalTo: itemIndexStepper.bottomAnchor, constant: 24),

      colorLabel.leadingAnchor.constraint(equalTo: textFieldLabel.leadingAnchor),
      colorLabel.centerYAnchor.constraint(equalTo: colorSegmentedControl.centerYAnchor),

      colorSegmentedControl.leadingAnchor.constraint(
        equalTo: colorLabel.trailingAnchor,
        constant: 12),
      colorSegmentedControl.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
      colorSegmentedControl.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),

      widthModeLabel.leadingAnchor.constraint(equalTo: colorLabel.leadingAnchor),
      widthModeLabel.topAnchor.constraint(
        equalTo: colorSegmentedControl.bottomAnchor, constant: 24),

      widthModePicker.leadingAnchor.constraint(equalTo: widthModeLabel.leadingAnchor),
      widthModePicker.trailingAnchor.constraint(equalTo: itemIndexLabel.trailingAnchor),
      widthModePicker.topAnchor.constraint(equalTo: widthModeLabel.bottomAnchor, constant: 8),
      widthModePicker.heightAnchor.constraint(equalToConstant: 144),

      heightModeLabel.leadingAnchor.constraint(equalTo: widthModePicker.leadingAnchor),
      heightModeLabel.topAnchor.constraint(equalTo: widthModePicker.bottomAnchor, constant: 24),

      heightModePicker.leadingAnchor.constraint(equalTo: heightModeLabel.leadingAnchor),
      heightModePicker.trailingAnchor.constraint(equalTo: widthModePicker.trailingAnchor),
      heightModePicker.topAnchor.constraint(equalTo: heightModeLabel.bottomAnchor, constant: 8),
      heightModePicker.heightAnchor.constraint(equalToConstant: 144),
      heightModePicker.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    ])
  }

  @objc
  private func updateAndValidateUIState() {
    sectionIndexStepper.minimumValue = 0
    sectionIndexStepper.maximumValue = Double(dataSourceCountsProvider.numberOfSections)

    let selectedSectionIndex = Int(sectionIndexStepper.value)
    itemIndexStepper.minimumValue = 0
    if selectedSectionIndex < dataSourceCountsProvider.numberOfSections {
      let numberOfItemsInSection = dataSourceCountsProvider.numberOfItemsInSection(
        withIndex: selectedSectionIndex)
      itemIndexStepper.maximumValue = Double(numberOfItemsInSection)
      itemIndexStepper.isEnabled = true
    } else {
      itemIndexStepper.maximumValue = 0
      itemIndexStepper.isEnabled = false
    }

    sectionIndexLabel.text = "Section: \(selectedSectionIndex)"
    itemIndexLabel.text = "Item: \(Int(itemIndexStepper.value))"
  }

  @objc
  private func viewTapped() {
    textField.resignFirstResponder()
  }

}

// MARK: UIPickerViewDataSource

extension ItemCreationPanelView: UIPickerViewDataSource {

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == widthModePicker {
      return 7
    } else if pickerView == heightModePicker {
      return 3
    } else {
      return 0
    }
  }

}

// MARK: UIPickerViewDelegate

extension ItemCreationPanelView: UIPickerViewDelegate {

  func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?)
    -> UIView
  {
    let label = (view as? UILabel) ?? UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .center

    if pickerView == widthModePicker {
      switch row {
      case 0: label.text = ".fullWidth(respectsHorizontalInsets: true)"
      case 1: label.text = ".fullWidth(respectsHorizontalInsets: false)"
      case 2: label.text = ".halfWidth"
      case 3: label.text = ".thirdWidth"
      case 4: label.text = ".fouthWidth"
      case 5: label.text = ".fifthWidth"
      case 6: label.text = ".fractionalWidth(divisor: 10)"
      default: label.text = nil
      }
    } else if pickerView == heightModePicker {
      switch row {
      case 0: label.text = ".static(height: 50)"
      case 1: label.text = ".dynamic"
      case 2: label.text = ".dynamicAndStretchToTallestItemInRow"
      default: label.text = nil
      }
    } else {
      label.text = nil
    }

    return label
  }

}

// MARK: UITextFieldDelegate

extension ItemCreationPanelView: UITextFieldDelegate {

  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    textField.resignFirstResponder()
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}

// MARK: - ItemCreationPanelViewState

struct ItemCreationPanelViewState {

  let sectionIndex: Int
  let itemIndex: Int
  let sizeMode: MagazineLayoutItemSizeMode
  let text: String
  let color: UIColor

}
