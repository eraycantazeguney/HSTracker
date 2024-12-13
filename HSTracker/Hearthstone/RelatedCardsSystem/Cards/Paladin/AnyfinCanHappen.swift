//
//  AnyfinCanHappen.swift
//  HSTracker
//
//  Created by Francisco Moraes on 12/13/24.
//  Copyright © 2024 Benjamin Michotte. All rights reserved.
//

import Foundation

class AnyfinCanHappen: ICardWithRelatedCards {
    required init() {
        
    }
    
    func getCardId() -> String {
        return CardIds.Collectible.Paladin.AnyfinCanHappen
    }

    func shouldShowForOpponent(opponent: Player) -> Bool {
        return false
    }

    func getRelatedCards(player: Player) -> [Card?] {
        return player.deadMinionsCards
            .compactMap { CardUtils.getProcessedCardFromEntity($0, player) }
            .filter { $0.isMurloc() }
            .sorted { $0.cost > $1.cost }
    }
}