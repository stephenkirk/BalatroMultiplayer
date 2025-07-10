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
	-- in_pool = function(self)
	-- 	return MP.LOBBY.config.ruleset == "ruleset_mp_experimental" and MP.LOBBY.code
	-- end,
	calculate = function(self, card, context)
		-- todo prob not this witchcraft
		-- todo try without
		-- return { x_mult = card.ability.extra }
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
	in_pool = function(self)
		return MP.LOBBY.config.ruleset == "ruleset_mp_experimental" and MP.LOBBY.code
	end,
	-- todo still needs to be tested
	calculate = function(self, card, context)
		nine_tally = 0
		for k, v in pairs(G.playing_cards) do
			if v:get_id() == 9 then
				nine_tally = nine_tally + 1
			end
		end
		return { nine_tally = nine_tally }
	end,
	calc_dollar_bonus = function(self, card)
		return card.ability.extra * (self.ability.nine_tally or 0)
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

	calc_dollar_bonus = function(self, card)
		if G.GAME.current_round.discards_used == 0 and G.GAME.current_round.discards_left > 0 then
			return G.GAME.current_round.discards_left * card.ability.extra
		end
	end,
})

SMODS.Enhancement:take_ownership("glass", {
	set_ability = function(self, card, initial, delay_sprites)
		local is_experimental_ruleset = MP.LOBBY.config.ruleset == "ruleset_mp_experimental"
		local lobby_is_active = MP.LOBBY.code or MP.LOBBY.ruleset_preview
		local multiplier = (is_experimental_ruleset and lobby_is_active) and 1.5 or 2

		-- Xmult is display, x_mult is internal. don't ask why, i don't know
		card.ability.Xmult = multiplier
		card.ability.x_mult = multiplier
		-- Now 1/3 chance to break! FUN!
		card.ability.extra = 3
	end,
}, true)

-- Current TheOrder implementation mostly
SMODS.Booster:take_ownership_by_kind("Standard", {
	create_card = function(self, card, i)
		local is_experimental = MP.LOBBY.config.ruleset == "ruleset_mp_experimental"

		local cen_pool = {}
		for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
			if v.key ~= "m_glass" then
				cen_pool[#cen_pool + 1] = v
			end
		end
		local card = create_playing_card({
			front = G.P_CARDS[_suit .. "_" .. _rank],
			center = pseudorandom_element(cen_pool, pseudoseed("spe_card")),
		}, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Spectral })

		debug.print("Card created:", card)

		return card

		-- local s_append = "" -- MP.get_booster_append(card)
		-- local b_append = MP.ante_based() .. s_append

		-- local _edition = poll_edition("standard_edition" .. b_append, 2, true)
		-- local _seal = SMODS.poll_seal({ mod = 10, key = "stdseal" .. b_append })
		-- local _enhancement = SMODS.poll_enhancement({ mod = 10, key = "stdenhancement" .. b_append })

		-- return {
		-- 	set = (pseudorandom(pseudoseed("stdset" .. b_append)) > 0.6) and "Enhanced" or "Base",
		-- 	edition = _edition,
		-- 	seal = _seal,
		-- 	area = G.pack_cards,
		-- 	skip_materialize = true,
		-- 	soulable = true,
		-- 	key_append = "sta" .. s_append,
		-- }
	end,
}, true)
