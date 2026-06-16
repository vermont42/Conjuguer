//
//  Fonts.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/8/21.
//

import SwiftUI

let workSansRegular = "WorkSans-Regular"
let workSansSemiBold = "WorkSans-SemiBold"

// Every custom SwiftUI font in the app lives here as a named global. `relativeTo:` keeps the base
// size unchanged but scales the font on the matching Dynamic Type curve (e.g. headings on .title
// rather than the default .body curve). Names describe the typographic role; a font shared by
// several roles is named for its primary one.

let bodyFont = Font.custom(workSansRegular, size: 20.0, relativeTo: .body)
let bodyEmphasisFont = Font.custom(workSansSemiBold, size: 20.0, relativeTo: .body)
let tableRowFont = Font.custom(workSansRegular, size: 18.0, relativeTo: .body)
let captionFont = Font.custom(workSansRegular, size: 16.0, relativeTo: .callout)
let subheadingFont = Font.custom(workSansSemiBold, size: 18.0, relativeTo: .title3)
let buttonFont = Font.custom(workSansSemiBold, size: 20.0, relativeTo: .title3)
let headingFont = Font.custom(workSansSemiBold, size: 22.0, relativeTo: .title)
let largeTitleFont = Font.custom(workSansSemiBold, size: 34.0, relativeTo: .largeTitle)
let scoreFont = Font.custom(workSansSemiBold, size: 64.0, relativeTo: .largeTitle)
let gridEndingFont = Font.custom(workSansRegular, size: 16.0, relativeTo: .body)
let gridPronounFont = Font.custom(workSansRegular, size: 14.0, relativeTo: .footnote)
let gridTenseLabelFont = Font.custom(workSansSemiBold, size: 14.0, relativeTo: .footnote)
let irregularityBadgeFont = Font.custom(workSansSemiBold, size: 14.0, relativeTo: .caption)
