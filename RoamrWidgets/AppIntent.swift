//
//  AppIntent.swift
//  RoamrWidgets
//
//  Created by Aydan Hawken on 18/07/23.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Roamr", default: "😃")
    var favoriteEmoji: String
}
