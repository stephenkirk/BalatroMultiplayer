MP.ReworkCenter("c_wraith", {
	rulesets = "sandbox",
	loc_key = "c_mp_sandbox_wraith",
	use = function(self, card, area, copier)
		local _card = copier or card
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.4,
			func = function()
				play_sound("timpani")
				-- rarity 2 = Uncommon (vanilla wraith uses rarity 3 = Rare)
				local joker = create_card("Joker", G.jokers, nil, 2, nil, nil, nil, "wra")
				joker:set_edition({ negative = true }, true)
				joker:add_to_deck()
				G.jokers:emplace(joker)
				_card:juice_up(0.3, 0.5)
				return true
			end,
		}))
		delay(0.6)
	end,
})
