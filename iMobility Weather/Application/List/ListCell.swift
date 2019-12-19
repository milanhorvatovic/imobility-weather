//
//  ListCell.swift
//  iMobility Weather
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

final class ListCell: UITableViewCell {
    
    typealias ModelType = Model.Service.Weather
    
    private lazy var _temperatureLabel: UILabel = self._createTemperatureLabel()
    private lazy var _temperatureFeelsLabel: UILabel = self._createTemperatureLabel()
    private lazy var _nameContainerView: UIView = self._createView()
    private lazy var _nameLabel: UILabel = self._createNameLabel()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .backgroundColor
        
        let temperaturesStack = self._createTemperaturesStackView()
        let stack = self._createHorizontalStackView()
        stack.spacing = 5
        stack.alignment = .center
        stack.distribution = .fill
        stack.addArrangedSubview(temperaturesStack)
        stack.addArrangedSubview(self._nameContainerView)
        
        self._nameContainerView.addSubview(self._nameLabel)
        self.contentView.addSubview(stack)
        self._nameLabel.leftAnchor.constraint(equalTo: self._nameContainerView.leftAnchor).isActive = true
        self._nameLabel.rightAnchor.constraint(equalTo: self._nameContainerView.rightAnchor).isActive = true
        self._nameLabel.topAnchor.constraint(equalTo: self._nameContainerView.topAnchor).isActive = true
        self._nameLabel.bottomAnchor.constraint(equalTo: self._nameContainerView.bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: self.contentView.leftAnchor,
                                    constant: 5).isActive = true
        stack.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                   constant: 2).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                      constant: -2).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ListCell {
    
    func configure(with model: ModelType?) {
        self._set(value: self._round(value: model?.values.temperature),
                  suffix: "°C",
                  to: self._temperatureLabel)
        self._set(value: self._round(value: model?.values.temperatureFeelsLike),
                  suffix: "°C",
                  to: self._temperatureFeelsLabel)
        self._set(value: model?.name,
                  to: self._nameLabel)
    }
    
}

extension ListCell {
    
    private func _set<T>(value: T?,
                         default: String = "-",
                         prefix: String? = nil,
                         suffix: String? = nil,
                         to label: UILabel) {
        var values: [String] = []
        if let value = prefix {
            values.append(value)
        }
        if let value = value {
            values.append(String(describing: value))
        }
        else {
            values.append(`default`)
        }
        if let value = suffix {
            values.append(value)
        }
        label.text = values.joined()
    }
    
    private func _round<T>(value: T?) -> T? where T: FloatingPoint {
        guard let value = value else {
            return nil
        }
        return round(value)
    }
    
}

extension ListCell {
    
    private func _createView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func _createLabel(with text: String? = nil,
                              font: UIFont = UIFont.systemFont(ofSize: 14,
                                                               weight: .regular)) -> UILabel {
        let label = UILabel()
        label.font = font
        label.numberOfLines = 1
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func _createHorizontalStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func _createVerticalStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func _createTemperatureLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func _createNameLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20,
                                       weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func _createTemperaturesStackView() -> UIStackView {
        let stackView = self._createHorizontalStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        
        let labelsStackView = self._createVerticalStackView()
        labelsStackView.distribution = .fillEqually
        labelsStackView.alignment = .fill
        let valuesStackView = self._createVerticalStackView()
        valuesStackView.distribution = .fillEqually
        valuesStackView.alignment = .fill
        
        let temperatureLabel = self._createLabel(with: "Real")
        temperatureLabel.setContentHuggingPriority(.defaultHigh,
                                                   for: .horizontal)
        self._temperatureLabel.setContentHuggingPriority(.defaultLow,
                                                         for: .horizontal)
        labelsStackView.addArrangedSubview(temperatureLabel)
        valuesStackView.addArrangedSubview(self._temperatureLabel)
        
        let temperatureFeelsLabel = self._createLabel(with: "Feels")
        temperatureFeelsLabel.setContentHuggingPriority(.defaultHigh,
                                                        for: .horizontal)
        self._temperatureFeelsLabel.setContentHuggingPriority(.defaultLow,
                                                              for: .horizontal)
        labelsStackView.addArrangedSubview(temperatureFeelsLabel)
        valuesStackView.addArrangedSubview(self._temperatureFeelsLabel)
        
        stackView.addArrangedSubview(labelsStackView)
        stackView.addArrangedSubview(valuesStackView)
        
        return stackView
    }
    
}
