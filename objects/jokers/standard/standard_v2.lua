MP.ReworkCenter({
	key = "j_idol",
	ruleset = MP.UTILS.get_standard_rulesets(),
	config = { extra = 1.5 },
})

MP.ReworkCenter({
	key = "j_golden_ticket",
	ruleset = MP.UTILS.get_standard_rulesets(),
	rarity = 2,
	cost = 6,
	in_pool = function(self, args)
		return true
	end,
})

MP.ReworkCenter({
	key = "j_selzer",
	ruleset = MP.UTILS.get_standard_rulesets(),
	rarity = 1,
	cost = 5,
	config = { hands_left = 10, effect_disabled = false },
	loc_vars = function(self, info_queue, card)
		return {
			key = self.key .. "_standard",
			-- todo might still have to return this
		}
	end,
	calculate = function(self, card, context)
		if context.first_hand_drawn then
			if MP.is_pvp_boss() then card.ability.extra.effect_disabled = true end
			local eval = function()
				return not MP.is_pvp_boss()
			end
			juice_card_until(card, eval, true)
		end
		if context.repetition and context.cardarea == G.play and not MP.is_pvp_boss() then
			return {
				repetitions = 1,
			}
		end
		if context.after and not context.blueprint and not MP.is_pvp_boss() then
			if card.ability.extra.hands_left - 1 <= 0 then
				SMODS.destroy_cards(card, nil, nil, true)
				return {
					message = localize("k_drank_ex"),
					colour = G.C.FILTER,
				}
			else
				card.ability.extra.hands_left = card.ability.extra.hands_left - 1
				return {
					message = card.ability.extra.hands_left .. "",
					colour = G.C.FILTER,
				}
			end
		end
		if context.end_of_round and context.game_over == false and context.main_eval then
			card.ability.extra.effect_disabled = false
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if MP.is_pvp_boss() then card.ability.extra.effect_disabled = true end
	end,
})

MP.ReworkCenter({
	key = "j_turtle_bean",
	ruleset = MP.UTILS.get_standard_rulesets(),
	rarity = 1,
	cost = 5,
	config = { extra = { h_size = 5, h_mod = 1, effect_disabled = false } },
	loc_vars = function(self, info_queue, card)
		return {
			key = self.key .. "_standard",
			vars = { card.ability.extra.h_size, card.ability.extra.h_mod, card.ability.extra.effect_disabled },
		}
	end,
	calculate = function(self, card, context)
		if context.first_hand_drawn and MP.is_pvp_boss() and not context.blueprint then
			G.hand:change_size(-card.ability.extra.h_size)
			card.ability.extra.effect_disabled = true
		end
		if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
			if MP.is_pvp_boss() then
				G.hand:change_size(card.ability.extra.h_size)
				card.ability.extra.effect_disabled = false
			else
				if card.ability.extra.h_size - card.ability.extra.h_mod <= 0 then
					SMODS.destroy_cards(card, nil, nil, true)
					return {
						message = localize("k_eaten_ex"),
						colour = G.C.FILTER,
					}
				else
					card.ability.extra.h_size = card.ability.extra.h_size - card.ability.extra.h_mod
					G.hand:change_size(-card.ability.extra.h_mod)
					return {
						message = localize({
							type = "variable",
							key = "a_handsize_minus",
							vars = { card.ability.extra.h_mod },
						}),
						colour = G.C.FILTER,
					}
				end
			end
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		if not MP.is_pvp_boss() then
			G.hand:change_size(card.ability.extra.h_size)
		else
			card.ability.extra.effect_disabled = true
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if not card.ability.extra.effect_disabled then G.hand:change_size(-card.ability.extra.h_size) end
	end,
})

MP.ReworkCenter({
	key = "j_ticket",
	ruleset = MP.UTILS.get_standard_rulesets(),
	rarity = 2,
	cost = 6,
})
