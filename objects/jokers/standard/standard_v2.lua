-- This is the example for defining a center rework
MP.ReworkCenter({
	key = "j_idol",
	ruleset = MP.UTILS.get_standard_rulesets(),
	config = { extra = 1.5 },
})

MP.ReworkCenter({
	key = "j_selzer",
	ruleset = MP.UTILS.get_standard_rulesets(),
	rarity = 1,
	cost = 5,
	-- todo diff calc
})

MP.ReworkCenter({
	key = "j_turtle_bean",
	ruleset = MP.UTILS.get_standard_rulesets(),
	rarity = 1,
	cost = 5,
	loc_vars = function(self, info_queue, card)
		return {
			key = self.key .. "_standard",
			vars = { card.ability.extra.xmult },
		}
	end,
	calculate = function(self, card, context)
		-- TODO
		-- If in PvP,
		-- 1. This should not give effect
		-- 2. Hand size should not be reduced at end of round
		-- Use G.hand:change_size(-card.ability.extra.h_size) for that

		if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
			if card.ability.extra.h_size - card.ability.extra.h_mod <= 0 then
				SMODS.destroy_cards(card, nil, nil, true)
				return {
					message = localize("k_eaten_ex"),
					colour = G.C.FILTER,
				}
			else
				-- See note about SMODS Scaling Manipulation on the wiki
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
	end,
})

MP.ReworkCenter({
	key = "j_ticket",
	ruleset = MP.UTILS.get_standard_rulesets(),
	rarity = 2,
	cost = 6,
})
