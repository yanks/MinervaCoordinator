//
// Copyright © 2019 Optimize Fitness Inc.
// Licensed under the MIT license
// https://github.com/OptimizeFitness/Minerva/blob/master/LICENSE
//

import Foundation
import RxSwift
import UIKit

public final class ButtonImageCellModel: BaseListCellModel, ListSelectableCellModel, ListBindableCellModel {

  fileprivate static let verticalMargin: CGFloat = 10
  fileprivate static let horizontalMargin: CGFloat = 4.0
  fileprivate static let imageMargin: CGFloat = 4.0

  public let iconImage = BehaviorSubject<UIImage?>(value: nil)

  public var directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

  public var numberOfLines = 0
  public var textAlignment: NSTextAlignment = .center
  public var buttonColor: UIColor?
  public var textColor: UIColor?
  public var backgroundColor: UIColor?

  public var allButtonsText: [String]
  public var imageContentMode: UIView.ContentMode = .scaleAspectFit
  public var imageColor: UIColor?

  public var borderWidth: CGFloat = 0
  public var borderRadius: CGFloat = 4
  public var borderColor: UIColor?

  fileprivate let text: String
  fileprivate let font: UIFont
  fileprivate let imageSize: CGSize

  private let cellIdentifier: String

  public init(identifier: String, imageSize: CGSize, text: String, font: UIFont) {
    self.cellIdentifier = identifier
    self.imageSize = imageSize
    self.text = text
    self.font = font
    self.allButtonsText = [text]
    super.init()
  }

  public convenience init(imageSize: CGSize, text: String, font: UIFont) {
    self.init(identifier: text, imageSize: imageSize, text: text, font: font)
  }

  // MARK: - BaseListCellModel

  override public var identifier: String {
    return self.cellIdentifier
  }

  override public func identical(to model: ListCellModel) -> Bool {
    guard let model = model as? Self, super.identical(to: model) else { return false }
    return numberOfLines == model.numberOfLines
      && textAlignment == model.textAlignment
      && buttonColor == model.buttonColor
      && textColor == model.textColor
      && allButtonsText == model.allButtonsText
      && imageContentMode == model.imageContentMode
      && imageColor == model.imageColor
      && borderWidth == model.borderWidth
      && borderRadius == model.borderRadius
      && borderColor == model.borderColor
      && text == model.text
      && font == model.font
      && imageSize == model.imageSize
      && backgroundColor == model.backgroundColor
      && directionalLayoutMargins == model.directionalLayoutMargins
  }

  override public func size(
    constrainedTo containerSize: CGSize,
    with templateProvider: () -> ListCollectionViewCell
  ) -> ListCellSize {
    let margins = templateProvider().layoutMargins
    let rowWidth = containerSize.width
    let textWidth =
      rowWidth - margins.left - margins.right - imageSize.width - ButtonImageCellModel.horizontalMargin * 4

    let textHeight = allButtonsText.map { $0.height(constraintedToWidth: textWidth, font: font) }.max() ?? 0

    let height = textHeight
      + ButtonImageCellModel.verticalMargin * 2
      + margins.top
      + margins.bottom
    return .explicit(size: CGSize(width: rowWidth, height: height))
  }

  // MARK: - ListSelectableCellModel
  public typealias SelectableModelType = ButtonImageCellModel
  public var selectionAction: SelectionAction?

  // MARK: - ListBindableCellModel
  public typealias BindableModelType = ButtonImageCellModel
  public var willBindAction: BindAction?
}

public final class ButtonImageCell: BaseReactiveListCell<ButtonImageCellModel> {
  private let label: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  private let buttonBackgroundView = UIView()

  private let marginContainer: UIView = {
    let view = UIView()
    return view
  }()

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()

  private var imageWidthConstraint: NSLayoutConstraint?
  private var imageHeightConstraint: NSLayoutConstraint?

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(buttonBackgroundView)
    contentView.addSubview(marginContainer)
    marginContainer.addSubview(imageView)
    marginContainer.addSubview(label)
    backgroundView = UIView()
    setupConstraints()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  override public func bind(model: ButtonImageCellModel, sizing: Bool) {
    super.bind(model: model, sizing: sizing)
    label.text = model.text
    label.font = model.font
    label.textAlignment = model.textAlignment
    label.numberOfLines = model.numberOfLines
    contentView.directionalLayoutMargins = model.directionalLayoutMargins
    remakeConstraints(with: model)

    guard !sizing else { return }

    imageView.contentMode = model.imageContentMode
    imageView.tintColor = model.imageColor
    label.textColor = model.textColor

    buttonBackgroundView.layer.borderWidth = model.borderWidth
    buttonBackgroundView.layer.borderColor = model.borderColor?.cgColor
    buttonBackgroundView.layer.cornerRadius = model.borderRadius
    buttonBackgroundView.backgroundColor = model.buttonColor
    backgroundView?.backgroundColor = model.backgroundColor

    model.iconImage.subscribe(onNext: { [weak self] in self?.imageView.image = $0 }).disposed(by: disposeBag)
  }
}

// MARK: - Constraints
extension ButtonImageCell {

  private func remakeConstraints(with model: ButtonImageCellModel) {
    imageWidthConstraint?.constant = model.imageSize.width
    imageHeightConstraint?.constant = model.imageSize.height
  }

  private func setupConstraints() {
    let layoutGuide = contentView.layoutMarginsGuide

    buttonBackgroundView.anchorTo(layoutGuide: layoutGuide)

    marginContainer.topAnchor.constraint(
      equalTo: layoutGuide.topAnchor
    ).isActive = true
    marginContainer.bottomAnchor.constraint(
      equalTo: layoutGuide.bottomAnchor
    ).isActive = true
    marginContainer.leadingAnchor.constraint(
      greaterThanOrEqualTo: layoutGuide.leadingAnchor
    ).isActive = true
    marginContainer.trailingAnchor.constraint(
      lessThanOrEqualTo: layoutGuide.trailingAnchor
    ).isActive = true
    marginContainer.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor).isActive = true

    imageView.leadingAnchor.constraint(equalTo: marginContainer.leadingAnchor, constant: ButtonImageCellModel.imageMargin).isActive = true
    imageView.topAnchor.constraint(equalTo: marginContainer.topAnchor, constant: ButtonImageCellModel.imageMargin).isActive = true
    imageView.bottomAnchor.constraint(equalTo: marginContainer.bottomAnchor, constant: -ButtonImageCellModel.imageMargin).isActive = true

    imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
    imageWidthConstraint?.isActive = true
    imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
    imageWidthConstraint?.isActive = true

    label.leadingAnchor.constraint(
      equalTo: imageView.trailingAnchor,
      constant: ButtonImageCellModel.imageMargin
    ).isActive = true
    label.trailingAnchor.constraint(equalTo: marginContainer.trailingAnchor).isActive = true
    label.topAnchor.constraint(equalTo: marginContainer.topAnchor, constant: ButtonImageCellModel.imageMargin).isActive = true
    label.bottomAnchor.constraint(equalTo: marginContainer.bottomAnchor, constant: -ButtonImageCellModel.imageMargin).isActive = true
    marginContainer.shouldTranslateAutoresizingMaskIntoConstraints(false)
    contentView.shouldTranslateAutoresizingMaskIntoConstraints(false)
  }
}