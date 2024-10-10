//
//  CrusaderAura.swift
//  HSTracker
//
//  Created by Francisco Moraes on 9/15/24.
//  Copyright © 2024 Benjamin Michotte. All rights reserved.
//

import Foundation

class CrusaderAura: EntityBasedEffect {
    // Properties
    override var cardId: String {
        return CardIds.NonCollectible.Neutral.CrusaderAura_CrusaderAuraCoreEnchantment
    }

    override var cardIdToShowInUI: String {
        return CardIds.Collectible.Paladin.CrusaderAuraCore
    }

    // Initializer
    required init(entityId: Int, isControlledByPlayer: Bool) {
        super.init(entityId: entityId, isControlledByPlayer: isControlledByPlayer)
    }

    // Computed properties
    override var effectDuration: EffectDuration {
        return .multipleTurns
    }

    override var effectTag: EffectTag {
        return .minionModification
    }
}
