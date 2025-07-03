MP.Ruleset({
	key = "experimental",
	multiplayer_content = true,
	banned_jokers = {
		"j_hanging_chad",
		"j_idol",
		"j_cloud_9",
		"j_delayed_grat",
	},
	banned_consumables = {
		"c_justice",
	},
	banned_vouchers = {},
	banned_enhancements = {},
	banned_tags = {},
	banned_blinds = {},

	reworked_jokers = {
		"j_mp_hanging_chad",
		"j_mp_idol",
		"j_mp_cloud_9",
		"j_mp_delayed_grat",
		"j_mp_conjoined_joker",
		"j_mp_defensive_joker",
		"j_mp_lets_go_gambling",
		"j_mp_pacifist",
		"j_mp_penny_pincher",
		"j_mp_pizza",
		"j_mp_skip_off",
		"j_mp_speedrun",
		"j_mp_taxes",
	},
	reworked_consumables = {
		"c_mp_asteroid",
	},
	reworked_vouchers = {},
	reworked_enhancements = {
		"m_glass",
	},
	reworked_tags = {},
	reworked_blinds = {
		"bl_mp_nemesis",
	},
}):inject()

SMODS.Joker({
	key = "hanging_chad",
	no_collection = true,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	perishable_compat = true,
	eternal_compat = true,
	rarity = 1,
	cost = 4,
	pos = { x = 9, y = 6 },
	config = { extra = 1, mp_sticker_balanced = true },
	loc_vars = function(self, info_queue, card)
		return { vars = {
			card.ability.extra,
		} }
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.repetition then
			if context.other_card == context.scoring_hand[1] then
				return {
					message = localize("k_again_ex"),
					repetitions = card.ability.extra,
					card = card,
				}
			end
			if context.other_card == context.scoring_hand[2] then
				return {
					message = localize("k_again_ex"),
					repetitions = card.ability.extra,
					card = card,
				}
			end
		end
	end,
	in_pool = function(self)
		return MP.LOBBY.config.ruleset == "ruleset_mp_experimental" and MP.LOBBY.code
	end,
})

-- j_idol=             {order = 127,  unlocked = false, discovered = false, blueprint_compat = true, perishable_compat = true, eternal_compat = true, rarity = 2, cost = 6, name = "The Idol", pos = {x=6,y=7}, set = "Joker", effect = "", config = {extra = 2}, unlock_condition = {type = 'chip_score', chips = 1000000}},
SMODS.Joker({
	key = "idol",
	no_collection = true,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	perishable_compat = true,
	eternal_compat = true,
	rarity = 3,
	cost = 8,
	pos = { x = 6, y = 7 },
	config = { extra = 2, mp_sticker_balanced = true },
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.extra,
				localize(G.GAME.current_round.idol_card.rank, "ranks"),
				localize(G.GAME.current_round.idol_card.suit, "suits_plural"),
				colours = { G.C.SUITS[G.GAME.current_round.idol_card.suit] },
			},
		}
	end,
	-- todo needs to reimplement calculate = function(self, card, context)... (the actual calculation logic)
	in_pool = function(self)
		return MP.LOBBY.config.ruleset == "ruleset_mp_experimental" and MP.LOBBY.code
	end,
})

-- j_cloud_9=          {order = 73,  unlocked = true, discovered = false, blueprint_compat = false, perishable_compat = true, eternal_compat = true, rarity = 2, cost = 7, name = "Cloud 9",set = "Joker", config = {extra = 1}, pos = {x=7,y=12}},
SMODS.Joker({
	key = "cloud_9",
	no_collection = true,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	perishable_compat = true,
	eternal_compat = true,
	rarity = 2,
	cost = 7,
	pos = { x = 7, y = 12 },
	config = { extra = 2, mp_sticker_balanced = true },
	loc_vars = function(self, info_queue, card) -- is this only for overview or possibly also used for calculations?
		-- feels like info text only
		-- unclear if we should use 'card' or 'self' though
		return { vars = {
			card.ability.extra,
			card.ability.nine_tally or 0,
		} }
	end,
	-- todo needs to reimplement calculate = function(self, card, context)... (the actual calculation logic)
	in_pool = function(self)
		return MP.LOBBY.config.ruleset == "ruleset_mp_experimental" and MP.LOBBY.code
	end,
})

-- j_delayed_grat=     {order = 35,  unlocked = true,  discovered = false, blueprint_compat = false, perishable_compat = true, eternal_compat = true, rarity = 1, cost = 4, name = "Delayed Gratification", pos = {x=4,y=3}, set = "Joker", effect = "Discard dollars", cost_mult = 1.0, config = {extra = 2}},
SMODS.Joker({
	key = "delayed_grat",
	no_collection = true,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	perishable_compat = true,
	eternal_compat = true,
	rarity = 1,
	cost = 4,
	pos = { x = 4, y = 3 },
	config = { extra = 3, mp_sticker_balanced = true },
	loc_vars = function(self, info_queue, card)
		return { vars = {
			card.ability.extra,
		} }
	end,
	-- todo needs to reimplement calculate = function(self, card, context)...
	in_pool = function(self)
		return MP.LOBBY.config.ruleset == "ruleset_mp_experimental" and MP.LOBBY.code
	end,
})

SMODS.Enhancement:take_ownership("glass", {
	set_ability = function(self, card, initial, delay_sprites)
		local x = MP.LOBBY.config.ruleset == "ruleset_mp_experimental"
				and (MP.LOBBY.code or MP.LOBBY.ruleset_preview)
				and 1.5
			or 2
		-- Xmult is display, x_mult is internal. don't ask why, i don't know
		card.ability.Xmult = x
		card.ability.x_mult = x
	end,
}, true)
