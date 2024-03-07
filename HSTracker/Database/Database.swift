//
//  Database.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 19/02/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation

class Database {
    static let currentSeason: Int = {
        let today = Date()
        let dc = Calendar.current.dateComponents(in: TimeZone.current, from: today)
        return (dc.year! - 2014) * 12 - 3 + dc.month!
    }()

    static func jsonFilesAreValid() -> Bool {
        for locale in Language.Hearthstone.allCases {

            let jsonFile = Paths.cardJson.appendingPathComponent("cardsDB.\(locale.rawValue).json")
            guard let jsonData = try? Data(contentsOf: jsonFile) else {
                logger.error("\(jsonFile) is not a valid file")
                return false
            }
            if (((try? JSONSerialization
                .jsonObject(with: jsonData, options: []) as? [[String: Any]]) as [[String: Any]]??)) == nil {
                    logger.error("\(jsonFile) is not a valid file")
                    return false
            }
        }
        return true
    }
    
    static let validCardSets = CardSet.allCases

    static let deckManagerCardTypes = ["all_types", "spell", "minion", "weapon"]
    static var deckManagerRaces = [Race]()

    // list of cards that are incorrectly tagged as BG
    static let battlegroundsExclusions: Set = [ "CORE_LOE_077" ]
    
    static var battlegroundRaces = [Race]()

    func loadDatabase(splashscreen: Splashscreen?, withLanguages langs: [Language.Hearthstone]) {
        autoreleasepool {
            for lang in langs {
                let file = Bundle(for: type(of: self))
                    .url(forResource: "Resources/Cards/cardsDB.\(lang.rawValue)",
                        withExtension: "json")

                guard let jsonFile = file else {
                    logger.error("Can't find cardsDB.\(lang.rawValue).json")
                    continue
                }

                logger.verbose("json file : \(jsonFile)")

                guard let jsonData = try? Data(contentsOf: jsonFile) else {
                    logger.error("\(jsonFile) is not a valid file")
                    continue
                }
                guard let jsonCards = ((try? JSONSerialization
                        .jsonObject(with: jsonData, options: []) as? [[String: Any]]) as [[String: Any]]??),
                    let cards = jsonCards else {
                                        logger.error("\(jsonFile) is not a valid file")
                    continue
                }

                if let splashscreen = splashscreen {
                    DispatchQueue.main.async {
                        let msg = String(format: String.localizedString("Loading %@ cards",
                                                                   comment: ""), lang.localizedString)
                        splashscreen.display(msg, total: Double(cards.count))
                    }
                }

                for jsonCard: [String: Any] in cards {
                    if let splashscreen = splashscreen {
                        DispatchQueue.main.async {
                            splashscreen.increment()
                        }
                    }

                    guard let cardId = jsonCard["id"] as? String,
                        let jsonSet = jsonCard["set"] as? String,
                        let set = CardSet(rawValue: jsonSet.lowercased()),
                        Database.validCardSets.contains(set) else { continue }

                    var index = Cards.indexOf(id: cardId)
                    
                    if index >= 0,
                        lang == .enUS && langs.count > 1 {
                        if let name = jsonCard["name"] as? String {
                            Cards.cards[index].enName = name
                        }
                        if (jsonCard["techLevel"] as? Int) != nil, let text = jsonCard["text"] as? String {
                            Cards.cards[index].enText = text
                        }
                    } else {
                        let card = Card()
                        card.jsonRepresentation = jsonCard
                        card.id = cardId
                        if let dbfId = jsonCard["dbfId"] as? Int {
                            card.dbfId = dbfId
                        }

                        card.isStandard = !CardSet.wildSets().contains(set) && !CardSet.classicSets().contains(set)

                        if let cost = jsonCard["cost"] as? Int {
                            card.cost = cost
                        } else {
                            card.cost = -1
                        }

                        if let cardRarity = jsonCard["rarity"] as? String,
                            let rarity = Rarity(rawValue: cardRarity.lowercased()) {
                            card.rarity = rarity
                        }

                        if let type = jsonCard["type"] as? String,
                            let cardType = CardType(rawString: type.lowercased()) {
                            card.type = cardType
                        }

                        if let cardClass = jsonCard["cardClass"] as? String,
                            let cardPlayerClass = CardClass(rawValue: cardClass.lowercased()) {
                            card.playerClass = cardPlayerClass
                        }

                        if let faction = jsonCard["faction"] as? String,
                            let cardFaction = Faction(rawValue: faction.lowercased()) {
                            card.faction = cardFaction
                        }

                        card.set = set
                        if let health = jsonCard["health"] as? Int {
                            card.health = health
                        }
                        if let attack = jsonCard["attack"] as? Int {
                            card.attack = attack
                        }
                        if let durability = jsonCard["durability"] as? Int {
                            card.durability = durability
                        }
                        if let overload = jsonCard["overload"] as? Int {
                            card.overload = overload
                        }
                        if let collectible = jsonCard["collectible"] as? Bool {
                            card.collectible = collectible
                        }
                        if let race = jsonCard["race"] as? String,
                            let cardRace = Race(rawValue: race.lowercased()) {
                            card.race = cardRace
                            if card.collectible && !Database.deckManagerRaces.contains(cardRace) {
                                Database.deckManagerRaces.append(cardRace)
                            }
                        }
                        if let races = jsonCard["races"] as? [String] {
                            card.races = races.compactMap { x in Race(rawValue: x.lowercased()) }
                            for race in card.races {
                                if card.collectible && !Database.deckManagerRaces.contains(race) {
                                    Database.deckManagerRaces.append(race)
                                }
                            }
                        }
                        if let flavor = jsonCard["flavor"] as? String {
                            card.flavor = flavor
                        }
                        if let name = jsonCard["name"] as? String {
                            card.name = name
                            if lang == .enUS && langs.count == 1 {
                                card.enName = name
                            }
                        }
                        if let text = jsonCard["text"] as? String {
                            card.text = text
                            if (jsonCard["techLevel"] as? Int) != nil, lang == .enUS && langs.count == 1 {
                                card.enText = text
                            }
                        }
                        if let artist = jsonCard["artist"] as? String {
                            card.artist = artist
                        }
                        if let mechanics = jsonCard["mechanics"] as? [String] {
                            for mechanic in mechanics {
                                card.mechanics.append(mechanic)
                            }
                        }
                        if let referencedTags = jsonCard["referencedTags"] as? [String] {
                            for tag in referencedTags {
                                card.mechanics.append(tag)
                            }
                        }
                        if index < 0 {
                            index = -index - 1
                        }
                        
                        if let multiClassGroup = jsonCard["multiClassGroup"] as? String {
                            if let group = MultiClassGroup(rawValue: multiClassGroup.lowercased()) {
                                card.multiClassGroup = group
                            }
                        }
                        
                        if let classes = jsonCard["classes"] as? [String] {
                            var res = [CardClass]()
                            for clazz in classes {
                                if let cl = CardClass(rawValue: clazz.lowercased()) {
                                    res.append(cl)
                                }
                            }
                            card.classes = res
                        }
                        
                        if let techLevel = jsonCard["techLevel"] as? Int {
                            card.techLevel = techLevel
                            card.bgRaces = card.races
                        }
                        
                        if let bgPool = jsonCard["isBattlegroundsPoolMinion"] as? Bool, !Database.battlegroundsExclusions.contains(cardId) {
                            card.battlegroundsPoolMinion = bgPool
                            Cards.battlegroundsMinions.append(card)
                        }
                        
                        if let battlegroundsSkinParentId = jsonCard["battlegroundsSkinParentId"] as? Int {
                            card.battlegroundsSkinParentId = battlegroundsSkinParentId
                        }

                        if let hideStats = jsonCard["hideStats"] as? Bool {
                            card.hideStats = hideStats
                        }
                        
                        if let mercenariesAbilityCooldown = jsonCard["mercenariesAbilityCooldown"] as? Int {
                            card.mercenariesAbilityCooldown = mercenariesAbilityCooldown
                        }
                        
                        if let armorTier = jsonCard["battlegroundsArmorTier"] as? Int {
                            card.battlegroundsArmorTier = armorTier
                        }
                        if let battlegroundsPoolSpell = jsonCard["isBattlegroundsPoolSpell"] as? Bool {
                            card.battlegroundsPoolSpell = battlegroundsPoolSpell
                        }
                        if card.type == .battleground_spell && card.techLevel > 0 && card.battlegroundsPoolSpell {
                            Cards.battlegroundsSpells.append(card)
                        }
                        Cards.cards.insert(card, at: index)
                        Cards.cardsById[card.id] = card
                    }
                }
            }
            for card in Cards.battlegroundsMinions.array() {
                if card.race != .invalid && card.race != .all && !Database.battlegroundRaces.contains(card.race) {
                    Database.battlegroundRaces.append(card.race)
                }
                if card.races.count > 0 && card.races[0] != .all {
                    for race in card.races where !Database.battlegroundRaces.contains(race) {
                        Database.battlegroundRaces.append(race)
                    }
                }
            }
            for card in Cards.battlegroundsMinions.filter({ x in x.race == .invalid }) {
                let race = Database.getRace(card: card)
                if race != .invalid {
                    card.bgRaces = [ race ]
                    logger.debug("Setting race for \"\(card.name)\" to \(race)")
                }
            }
        }
    }
    
    static func getRace(card: Card) -> Race {
        let racesInText = Race.allCases.filter({ x in
            x != .all && x != .invalid
        }).filter({ x in
            let raceText = x == .mechanical ? "Mech" : "\(x)".capitalized
            return card.enText.contains(raceText)
        })
        if racesInText.count == 1 {
            return racesInText.first!
        }
        return card.race
    }
}
