//
//  WelcomeDataSource.swift
//  MinervaExample
//
//  Copyright © 2019 Optimize Fitness, Inc. All rights reserved.
//

import Foundation
import Minerva
import RxSwift
import UIKit

public final class WelcomeDataSource: DataSource {
	public enum Action {
		case createAccount
		case login
	}

	private let actionsSubject = PublishSubject<Action>()
	public var actions: Observable<Action> { actionsSubject.asObservable() }

	private let sectionsSubject = BehaviorSubject<[ListSection]>(value: [])
	public var sections: Observable<[ListSection]> { sectionsSubject.asObservable() }

	private let disposeBag = DisposeBag()

	public init() {
		sectionsSubject.onNext([createSection()])
	}

	// MARK: - Private

	private func createSection() -> ListSection {
		let topDynamicMarginModel = MarginCellModel(cellIdentifier: "topDynamicMarginModel", height: nil)

		let logoModel = ImageCellModel(image: Asset.Logo.image, width: 120.0, height: 120.0)
		logoModel.imageColor = .black
		logoModel.contentMode = .scaleAspectFit

		let personalizedGuidanceModel = LabelCell.Model(text: "WORKOUTS", font: UIFont.title1.bold)
		personalizedGuidanceModel.textColor = .black
		personalizedGuidanceModel.textAlignment = .center
		personalizedGuidanceModel.bottomMargin = 20
		personalizedGuidanceModel.topMargin = 30

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 20
		let attributedString = NSAttributedString(
			string: "Quickly log your calorie intake for each workout and track your calories over time. Easily see when you hit and miss your daily calorie goal.",
			font: .subheadline,
			fontColor: .black
		)

		let mutableString = NSMutableAttributedString(attributedString: attributedString)
		mutableString.addAttribute(
			NSAttributedString.Key.paragraphStyle,
			value: paragraphStyle,
			range: NSRange(location: 0, length: mutableString.length)
		)
		let paragraphCellModel = LabelCell.Model(attributedText: mutableString)
		paragraphCellModel.textAlignment = .center
		paragraphCellModel.bottomMargin = 60

		let newAccountModel = BorderLabelCellModel(text: "SETUP NEW ACCOUNT", font: .subheadline, textColor: .white)
		newAccountModel.textAlignment = .center
		newAccountModel.buttonColor = .selectable
		newAccountModel.selectionAction = { [weak self] _, _ in
			guard let strongSelf = self else { return }
			strongSelf.actionsSubject.onNext(.createAccount)
		}

		let existingAccountModel = LabelCell.Model(text: "USE EXISTING ACCOUNT", font: .subheadline)
		existingAccountModel.textAlignment = .center
		existingAccountModel.selectionAction = { [weak self] _, _ -> Void in
			guard let strongSelf = self else { return }
			strongSelf.actionsSubject.onNext(.login)
		}
		existingAccountModel.textColor = .selectable
		existingAccountModel.topMargin = 30

		let bottomDynamicMarginModel = MarginCellModel(cellIdentifier: "bottomDynamicMarginModel", height: nil)
		let bottomMarginModel = BottomMarginCellModel()

		let cellModels: [ListCellModel] = [
			topDynamicMarginModel,
			logoModel,
			personalizedGuidanceModel,
			paragraphCellModel,
			newAccountModel,
			existingAccountModel,
			bottomDynamicMarginModel,
			bottomMarginModel
		]

		let section = ListSection(cellModels: cellModels, identifier: "SECTION")

		return section
	}

}