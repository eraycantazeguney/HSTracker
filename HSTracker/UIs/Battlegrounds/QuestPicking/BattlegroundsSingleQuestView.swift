//
//  BattlegroundsSingleQuestView.swift
//  HSTracker
//
//  Created by Francisco Moraes on 12/14/22.
//  Copyright © 2022 Benjamin Michotte. All rights reserved.
//

import Foundation
import CustomToolTip

class BattlegroundsSingleQuestView: NSView {
    @IBOutlet var contentView: NSView!
    
    @IBOutlet var avgPlacementBox: NSBox!
    @IBOutlet var avgPlacementLabel: NSTextField!
    @IBOutlet var avgPlacementTooltip: NSView!
    
    @IBOutlet var tierBox: NSBox!
    @IBOutlet var tierLabel: NSTextField!
    @IBOutlet var tierTooltip: NSView!
    
    @IBOutlet var pickRateBox: NSBox!
    @IBOutlet var pickRateLabel: NSTextField!
    @IBOutlet var pickRateTooltip: NSView!
    
    @IBOutlet var compositionView: BattlegroundsCompositionPopularity!
    
    let viewModel: BattlegroundsSingleQuestViewModel
    
    @objc dynamic var tierTooltipText = ""
    @objc dynamic var tierTooltipTitle   = ""
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 252, height: 778   )
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    init(frame frameRect: NSRect, viewModel: BattlegroundsSingleQuestViewModel) {
        self.viewModel = viewModel
        super.init(frame: frameRect)
        commonInit()
    }
    
    private func commonInit() {
        NibHelper.loadNib(Self.self, self)
        
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.frame = self.bounds
        
        compositionView.viewModel = viewModel.compVM
        
        update()
        
        avgPlacementBox.customToolTip = avgPlacementTooltip
        avgPlacementBox.customToolTipMargins = CGSize(width: 0, height: 0)
        avgPlacementBox.customToolTipInsets = CGSize(width: 25, height: 0)
        avgPlacementTooltip.updateTrackingAreas_CustomToolTip()
        
        tierBox.customToolTip = tierTooltip
        tierBox.customToolTipMargins = CGSize(width: 0, height: 0)
        tierBox.customToolTipInsets = CGSize(width: 25, height: 0)
        tierTooltip.updateTrackingAreas_CustomToolTip()
        
        pickRateBox.customToolTip = pickRateTooltip
        pickRateBox.customToolTipMargins = CGSize(width: 0, height: 0)
        pickRateBox.customToolTipInsets = CGSize(width: 25, height: 0)
        pickRateTooltip.updateTrackingAreas_CustomToolTip()
        
        compositionView.update()
    }
    
    func update() {
        avgPlacementLabel.textColor = NSColor.fromHexString(hex: viewModel.avgPlacementColor) ?? NSColor.white
        if let avg = viewModel.avgPlacement {
            avgPlacementLabel.doubleValue = avg
        } else {
            avgPlacementLabel.stringValue = "—" // em dash
        }
        
        tierBox.wantsLayer = true
        tierBox.layer = viewModel.tierGradient
        if let tier = viewModel.tier {
            tierLabel.intValue = Int32(tier)
        } else {
            tierLabel.stringValue = "—" // em dash
        }
        
        if let pickRate = viewModel.pickRate {
            pickRateLabel.doubleValue = pickRate / 100.0
        } else {
            pickRateLabel.stringValue = "—" // em dash
        }
        
        tierTooltipTitle = viewModel.tierTooltipTitle
        tierTooltipText = viewModel.tierTooltipText
    }
}
