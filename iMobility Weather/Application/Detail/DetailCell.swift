//
//  DetailCell.swift
//  iMobility Weather
//
//  Created by Milan Horvatovic on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

final class DetailCell: UITableViewCell {
    
    typealias ModelType = Model.Content.Forecast
    
    private lazy var _timeLabel: UILabel = self._createLabel()
    private lazy var _conditionLabel: UILabel = self._createConditionLabel()
    
    private lazy var _temperatureLabel: UILabel = self._createTemperatureLabel()
    private lazy var _temperatureFeelsLabel: UILabel = self._createTemperatureLabel()
    
    private lazy var _temperatureMinLabel: UILabel = self._createTemperatureLabel()
    private lazy var _temperatureMaxLabel: UILabel = self._createTemperatureLabel()
    
    private static let _timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
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
        stack.addArrangedSubview(self._timeLabel)
        stack.addArrangedSubview(self._conditionLabel)
        stack.addArrangedSubview(temperaturesStack)
        
        self._timeLabel.setContentHuggingPriority(.defaultHigh,
                                                  for: .horizontal)
        self._conditionLabel.setContentHuggingPriority(.defaultLow,
                                                       for: .horizontal)
        temperaturesStack.setContentHuggingPriority(.required,
                                                    for: .horizontal)
        
        self.contentView.addSubview(stack)
        stack.leftAnchor.constraint(equalTo: self.contentView.leftAnchor,
                                    constant: 5).isActive = true
        stack.rightAnchor.constraint(equalTo: self.contentView.rightAnchor,
                                     constant: -2).isActive = true
        stack.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                   constant: 2).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                      constant: -2).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DetailCell {
    
    func configure(with model: ModelType?) {
        self._set(value: self._time(from: model?.service.date),
                  to: self._timeLabel)
        self._set(value: model?.service.condition.name,
                  to: self._conditionLabel)
        
        self._set(value: self._round(value: model?.service.values.temperature),
                  suffix: "°C",
                  to: self._temperatureLabel)
        self._set(value: self._round(value: model?.service.values.temperatureFeelsLike),
                  suffix: "°C",
                  to: self._temperatureFeelsLabel)
        self._set(value: self._round(value: model?.service.values.temperatureMin),
                  suffix: "°C",
                  to: self._temperatureMinLabel)
        self._set(value: self._round(value: model?.service.values.temperatureMax),
                  suffix: "°C",
                  to: self._temperatureMaxLabel)
        
    }
    
}

extension DetailCell {
    
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
    
    private func _time(from date: Date?) -> String? {
        guard let date = date else {
            return nil
        }
        return type(of: self)._timeFormatter.string(from: date)
    }
    
}

extension DetailCell {
    
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
    
    private func _createConditionLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20,
                                       weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func _createTemperaturesStackView() -> UIStackView {
        let stackView = self._createHorizontalStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        
        stackView.addArrangedSubview(self._createTemperaturesRealFeelsStackView())
        stackView.addArrangedSubview(self._createTemperaturesMinMaxStackView())
        
        return stackView
    }
    
    private func _createTemperaturesRealFeelsStackView() -> UIStackView {
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
    
    private func _createTemperaturesMinMaxStackView() -> UIStackView {
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
        
        let temperatureMinLabel = self._createLabel(with: "Min")
        temperatureMinLabel.setContentHuggingPriority(.defaultHigh,
                                                      for: .horizontal)
        self._temperatureMinLabel.setContentHuggingPriority(.defaultLow,
                                                            for: .horizontal)
        labelsStackView.addArrangedSubview(temperatureMinLabel)
        valuesStackView.addArrangedSubview(self._temperatureMinLabel)
        
        let temperatureMaxLabel = self._createLabel(with: "Max")
        temperatureMaxLabel.setContentHuggingPriority(.defaultHigh,
                                                      for: .horizontal)
        self._temperatureMaxLabel.setContentHuggingPriority(.defaultLow,
                                                            for: .horizontal)
        labelsStackView.addArrangedSubview(temperatureMaxLabel)
        valuesStackView.addArrangedSubview(self._temperatureMaxLabel)
        
        stackView.addArrangedSubview(labelsStackView)
        stackView.addArrangedSubview(valuesStackView)
        
        return stackView
    }
    
}
