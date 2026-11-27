//
//  FlowLayout.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/27/26.
//

import SwiftUI

/// Lays its children out in rows, wrapping to a new row when the next child would not fit. Each
/// child is offered the row's width, so that a child wider than a row wraps its own text rather
/// than overflowing.
struct FlowLayout: SwiftUI.Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let rows = rows(for: subviews, width: proposal.width ?? .infinity)
    let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
    let width = rows.map(\.width).max() ?? 0
    return CGSize(width: proposal.width ?? width, height: height)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    var y = bounds.minY
    for row in rows(for: subviews, width: bounds.width) {
      var x = bounds.minX
      for (index, size) in zip(row.indices, row.sizes) {
        // Centered in its row, so that a sentence's words line up with the field between them.
        subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2), proposal: ProposedViewSize(size))
        x += size.width + spacing
      }
      y += row.height + spacing
    }
  }

  private struct Row {
    var indices: [Int] = []
    var sizes: [CGSize] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
  }

  private func rows(for subviews: Subviews, width: CGFloat) -> [Row] {
    let childProposal = ProposedViewSize(width: width.isFinite ? width : nil, height: nil)
    var rows: [Row] = []
    var current = Row()
    for index in subviews.indices {
      let size = subviews[index].sizeThatFits(childProposal)
      let widthWithChild = current.indices.isEmpty ? size.width : current.width + spacing + size.width
      if widthWithChild > width, !current.indices.isEmpty {
        rows.append(current)
        current = Row()
      }
      current.width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
      current.height = max(current.height, size.height)
      current.indices.append(index)
      current.sizes.append(size)
    }
    if !current.indices.isEmpty {
      rows.append(current)
    }
    return rows
  }
}
