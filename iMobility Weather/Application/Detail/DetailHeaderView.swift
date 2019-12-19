//
//  DetailHeaderView.swift
//  iMobility Weather
//
//  Created by Milan Horvatovic on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

final class DetailHeaderView: UIView {
    
    private lazy var atLabel: UILabel = self._createAtLabel()
    private lazy var temperatureLabel: UILabel = self._createTemperatureLabel()
    
    private lazy var descriptionLabel: UILabel = self._createLabel()
    
    private lazy var feelsLikeLabel: UILabel = self._createLabel()
    private lazy var humidityLabel: UILabel = self._createLabel()
    private lazy var pressureLabel: UILabel = self._createLabel()
    private lazy var windLabel: UILabel = self._createLabel()
    
    private static let _timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .backgroundColor
        
        let previewStackView = self._createSummaryStackView()
        let detailStackView = self._createDetailStackView()
        let mainStackView = self._createHorizontalStackView()
        mainStackView.addArrangedSubview(previewStackView)
        mainStackView.addArrangedSubview(detailStackView)
        
        self.addSubview(mainStackView)
        mainStackView.leftAnchor.constraint(equalTo: self.leftAnchor,
                                            constant: 5).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: self.rightAnchor,
                                             constant: -5).isActive = true
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor,
                                           constant: 5).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                              constant: -5).isActive = true
        previewStackView.widthAnchor.constraint(equalTo: self.widthAnchor,
                                                multiplier: 0.5).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DetailHeaderView {
    
    func configure(with model: Model.Content.Weather) {
        self._set(value: self._time(from: model.service?.date),
                  to: self.atLabel)
        self._set(value: self._round(value: model.service?.values.temperature),
                  suffix: "°C",
                  to: self.temperatureLabel)
        
        self._set(value: model.service?.condition.name,
                  to: self.descriptionLabel)
        self._set(value: self._round(value: model.service?.values.temperatureFeelsLike),
                  suffix: "°C",
                  to: self.feelsLikeLabel)
        self._set(value: model.service?.values.humidity,
                  suffix: "%",
                  to: self.humidityLabel)
        self._set(value: model.service?.values.pressure,
                  suffix: "hPa",
                  to: self.pressureLabel)
        self._set(value: self._round(value: model.service?.wind.speed),
                  suffix: " m/s",
                  to: self.windLabel)
    }
    
}

extension DetailHeaderView {
    
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

extension DetailHeaderView {
    
    private func _createLabel(with text: String? = nil,
                              font: UIFont = UIFont.systemFont(ofSize: 17,
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
    
    private func _createAtLabel() -> UILabel {
        return self._createLabel(font: UIFont.systemFont(ofSize: 12,
                                                         weight: .regular))
    }
    
    private func _createTemperatureLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 45,
                                       weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func _createSummaryStackView() -> UIStackView {
        let stackView = self._createVerticalStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        
        let atStackView = self._createHorizontalStackView()
        let atLabel = self._createLabel(with: "Current",
                                        font: UIFont.systemFont(ofSize: 12,
                                                                weight: .regular))
        atLabel.setContentHuggingPriority(.defaultHigh,
                                          for: .horizontal)
        self.atLabel.setContentHuggingPriority(.defaultLow,
                                               for: .horizontal)
        atStackView.addArrangedSubview(atLabel)
        atStackView.addArrangedSubview(self.atLabel)
        atStackView.spacing = 2
        stackView.addArrangedSubview(atStackView)
        
        self.temperatureLabel.setContentHuggingPriority(.required,
                                                        for: .horizontal)
        self.temperatureLabel.setContentCompressionResistancePriority(.required,
                                                                      for: .horizontal)
        stackView.addArrangedSubview(self.temperatureLabel)
        
        return stackView
    }
    
    private func _createDetailStackView() -> UIStackView {
        let stackView = self._createVerticalStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 2
        
        self.descriptionLabel.textAlignment = .center
        stackView.addArrangedSubview(self.descriptionLabel)
        
        let feelsLikeStackView = self._createHorizontalStackView()
        let feelsLikeLabel = self._createLabel(with: "Feels Like")
        feelsLikeLabel.setContentHuggingPriority(.defaultLow,
                                                 for: .horizontal)
        self.feelsLikeLabel.setContentHuggingPriority(.defaultHigh,
                                                      for: .horizontal)
        feelsLikeStackView.addArrangedSubview(feelsLikeLabel)
        feelsLikeStackView.addArrangedSubview(self.feelsLikeLabel)
        stackView.addArrangedSubview(feelsLikeStackView)
        
        let humidityStackView = self._createHorizontalStackView()
        let humidityLabel = self._createLabel(with: "Humidity")
        humidityLabel.setContentHuggingPriority(.defaultLow,
                                                for: .horizontal)
        self.humidityLabel.setContentHuggingPriority(.defaultHigh,
                                                     for: .horizontal)
        humidityStackView.addArrangedSubview(humidityLabel)
        humidityStackView.addArrangedSubview(self.humidityLabel)
        stackView.addArrangedSubview(humidityStackView)
        
        let pressureStackView = self._createHorizontalStackView()
        let pressureLabel = self._createLabel(with: "Pressure")
        pressureLabel.setContentHuggingPriority(.defaultLow,
                                                for: .horizontal)
        self.pressureLabel.setContentHuggingPriority(.defaultHigh,
                                                     for: .horizontal)
        pressureStackView.addArrangedSubview(pressureLabel)
        pressureStackView.addArrangedSubview(self.pressureLabel)
        stackView.addArrangedSubview(pressureStackView)
        
        let windStackView = self._createHorizontalStackView()
        let windLabel = self._createLabel(with: "Gusts")
        windLabel.setContentHuggingPriority(.defaultLow,
                                            for: .horizontal)
        self.windLabel.setContentHuggingPriority(.defaultHigh,
                                                 for: .horizontal)
        windStackView.addArrangedSubview(windLabel)
        windStackView.addArrangedSubview(self.windLabel)
        stackView.addArrangedSubview(windStackView)
        
        return stackView
    }
    
}
