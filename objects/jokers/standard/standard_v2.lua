-- idol: X2 → X1.5. not broken because it's random - broken because it centralizes
-- the entire meta. every decision becomes "did i get idol / am i playing around idol"
-- straight nerf, no sweeteners.
MP.ReworkCenter("j_idol", {
	rulesets = MP.UTILS.get_standard_rulesets(),
	config = { extra = 1.5 },
})

-- golden ticket: common → uncommon. ~3x rarer in shops (1.15% → 0.40%).
-- also removed gold card gating - missing early gold card was already polarizing,
-- making ticket rarer would make that worse.
MP.ReworkCenter("j_ticket", {
	rulesets = MP.UTILS.get_standard_rulesets(),
	rarity = 2,
	cost = 6,
	enhancement_gate = false,
})

-- seltzer: uncommon → common, disabled in pvp. 10 uses then self-destructs.
-- common rarity makes this an eco card now - cheap shop pickup for pve value.
-- pvp disable because players find it at different times, so one player's seltzer
-- expires mid-match while the other's is still live.
MP.ReworkCenter("j_selzer", {
	rulesets = MP.UTILS.get_standard_rulesets(),
	loc_key = "j_mp_selzer_standard",
	rarity = 1,
	cost = 5,
	config = { extra = { hands_left = 10, effect_disabled = false } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.hands_left } }
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

-- turtle bean: same treatment as seltzer. uncommon → common eco card, disabled in pvp.
-- hand size manipulation in head-to-head is another coinflip vector - who found it
-- earlier, whose degrades first. preserves pve identity while removing the
-- multiplayer timing lottery.
MP.ReworkCenter("j_turtle_bean", {
	rulesets = MP.UTILS.get_standard_rulesets(),
	loc_key = "j_mp_turtle_bean_standard",
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
		return true -- magic - override vanilla behavior
	end,
	remove_from_deck = function(self, card, from_debuff)
		if not card.ability.extra.effect_disabled then G.hand:change_size(-card.ability.extra.h_size) end
		return true -- magic - override vanilla behavior
	end,
})

-- comeback money nerf
-- if you die in pve then you get half the comeback money
-- some logic can be found in defensive joker rework (for stake checkups)
-- we also need some weird logic to ensure this toggles on and off
