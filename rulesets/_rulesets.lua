G.P_CENTER_POOLS.Ruleset = {}
MP.Rulesets = {}
MP.Ruleset = SMODS.GameObject:extend({
	obj_table = {},
	obj_buffer = {},
	required_params = {
		"key",
		"multiplayer_content",
		"banned_jokers",
		"banned_consumables",
		"banned_vouchers",
		"banned_enhancements",
	},
	class_prefix = "ruleset",
	inject = function(self)
		MP.Rulesets[self.key] = self
		if not G.P_CENTER_POOLS.Ruleset then
			G.P_CENTER_POOLS.Ruleset = {}
		end
		table.insert(G.P_CENTER_POOLS.Ruleset, self)
	end,
	process_loc_text = function(self)
		SMODS.process_loc_text(G.localization.descriptions["Ruleset"], self.key, self.loc_txt)
	end,
})

MP.BANNED_OBJECTS = {
	jokers = {},
	consumables = {},
	vouchers = {},
	enhancements = {},
	tags = {},
	blinds = {},
}

function new_in_pool_for_blind(v) -- For blinds specifically, in_pool does overwrite basic checks like minimum ante, so we need to repackage all basic checks inside the new in_pool
	if MP.LOBBY.code then
		return false
	elseif
		not v.boss.showdown
		and (
			v.boss.min <= math.max(1, G.GAME.round_resets.ante)
			and ((math.max(1, G.GAME.round_resets.ante)) % G.GAME.win_ante ~= 0 or G.GAME.round_resets.ante < 2)
		)
	then
		return true
	elseif v.boss.showdown and G.GAME.round_resets.ante % G.GAME.win_ante == 0 and G.GAME.round_resets.ante >= 2 then
		return true
	else
		return false
	end
end

function MP.apply_rulesets()
	for _, ruleset in pairs(MP.Rulesets) do
		local function process_banned_items(banned_items, banned_table)
			if not banned_items then
				return
			end
			for _, item_key in ipairs(banned_items) do
				banned_table[item_key] = banned_table[item_key] or {}
				banned_table[item_key][ruleset.key] = true
			end
		end

		local banned_types = {
			{ items = ruleset.banned_jokers, table = MP.BANNED_OBJECTS.jokers },
			{ items = ruleset.banned_consumables, table = MP.BANNED_OBJECTS.consumables },
			{ items = ruleset.banned_vouchers, table = MP.BANNED_OBJECTS.vouchers },
			{ items = ruleset.banned_enhancements, table = MP.BANNED_OBJECTS.enhancements },
			{ items = ruleset.banned_tags, table = MP.BANNED_OBJECTS.tags },
			{ items = ruleset.banned_blinds, table = MP.BANNED_OBJECTS.blinds },
		}

		for _, banned_type in ipairs(banned_types) do
			process_banned_items(banned_type.items, banned_type.table)
		end
	end

	local object_types = {
		{ objects = MP.BANNED_OBJECTS.jokers, mod = SMODS.Joker, global_banned = MP.DECK.BANNED_JOKERS },
		{ objects = MP.BANNED_OBJECTS.consumables, mod = SMODS.Consumable, global_banned = MP.DECK.BANNED_CONSUMABLES },
		{ objects = MP.BANNED_OBJECTS.vouchers, mod = SMODS.Voucher, global_banned = MP.DECK.BANNED_VOUCHERS },
		{
			objects = MP.BANNED_OBJECTS.enhancements,
			mod = SMODS.Enhancement,
			global_banned = MP.DECK.BANNED_ENHANCEMENTS,
		},
		{ objects = MP.BANNED_OBJECTS.tags, mod = SMODS.Tag, global_banned = MP.DECK.BANNED_TAGS },
		{ objects = MP.BANNED_OBJECTS.blinds, mod = SMODS.Blind, global_banned = MP.DECK.BANNED_BLINDS },
	}

	for _, type in ipairs(object_types) do
		for obj_key, rulesets in pairs(type.objects) do
			-- Find object with object key, using the same method as take_ownership
			local obj = type.mod.obj_table[obj_key] or (type.mod.get_obj and type.mod:get_obj(obj_key))

			if obj then
				local old_in_pool = obj.in_pool
				type.mod:take_ownership(obj_key, {
					orig_in_pool = old_in_pool, -- Save the original in_pool function inside the object itself
					in_pool = function(self) -- Update the in_pool function
						if rulesets[MP.LOBBY.config.ruleset] and MP.LOBBY.code then
							return false
						elseif self.orig_in_pool then
							-- behave like the original in_pool function if it's not nil
							return self:orig_in_pool()
						else
							return self.set ~= "Blind" or new_in_pool_for_blind(self) -- in_pool returning true doesn't overwrite original checks EXCEPT for blinds
						end
					end,
				}, true)
			else
				sendWarnMessage(("Cannot ban %s: Does not exist."):format(obj_key), type.mod.set)
			end
		end
		for obj_key, _ in pairs(type.global_banned) do
			type.mod:take_ownership(obj_key, {
				in_pool = function(self)
					if self.set ~= "Blind" then
						return not MP.LOBBY.code
					else
						return new_in_pool_for_blind(self)
					end
				end,
			}, true)
		end
	end
end

MP.ACTIVE_RULESET_OVERRIDES = {}

function MP.apply_ruleset_overrides(ruleset_key)
	MP.clear_ruleset_overrides()

	if ruleset_key == "ruleset_mp_standard" then
		MP.apply_standard_overrides()
	elseif ruleset_key == "ruleset_mp_experimental" then
		MP.apply_experimental_overrides()
	end

	print("Ruleset applied: " .. ruleset_key)
	sendDebugMessage("Ruleset applied: " .. ruleset_key)

	MP.ACTIVE_RULESET_OVERRIDES.current_ruleset = ruleset_key
end

-- TODO not fully implemented yet - but doesn't need to be until release
function MP.clear_ruleset_overrides()
	-- copypaste from smods
	-- TODO copypaste from 506a instead
	-- SMODS.Enhancement:take_ownership("glass", {
	-- 	calculate = function(self, card, context)
	-- 		if
	-- 			context.destroy_card
	-- 			and context.cardarea == G.play
	-- 			and context.destroy_card == card
	-- 			and SMODS.pseudorandom_probability(card, "glass", 1, card.ability.extra)
	-- 		then
	-- 			card.glass_trigger = true
	-- 			return { remove = true }
	-- 		end
	-- 	end,
	-- })

	-- copypaste from the order stuff
	SMODS.Booster:take_ownership_by_kind("Standard", {
		create_card = function(self, card, i)
			local s_append = "" -- MP.get_booster_append(card)
			local b_append = MP.ante_based() .. s_append

			local _edition = poll_edition("standard_edition" .. b_append, 2, true)
			local _seal = SMODS.poll_seal({ mod = 10, key = "stdseal" .. b_append })

			return {
				set = (pseudorandom(pseudoseed("stdset" .. b_append)) > 0.6) and "Enhanced" or "Base",
				edition = _edition,
				seal = _seal,
				area = G.pack_cards,
				skip_materialize = true,
				soulable = true,
				key_append = "sta" .. s_append,
			}
		end,
	}, true)
	MP.ACTIVE_RULESET_OVERRIDES = {}
end

-- TODO: Should probably be defined in each ruleset itself
-- and called from here
function MP.apply_standard_overrides()
	MP.ACTIVE_RULESET_OVERRIDES.glass = {
		type = "enhancement",
		key = "m_glass",
	}

	-- Apply standard ruleset glass override (1.5x instead of 2x)
	SMODS.Enhancement:take_ownership("glass", {
		set_ability = function(self, card, initial, delay_sprites)
			card.ability.Xmult = 1.5
			card.ability.x_mult = 1.5
		end,
	}, true)
end

function MP.apply_experimental_overrides()
	MP.ACTIVE_RULESET_OVERRIDES.glass = {
		type = "enhancement",
		key = "m_glass",
	}

	-- Apply experimental glass override (2x with 1/3 break chance)
	SMODS.Enhancement:take_ownership("glass", {
		set_ability = function(self, card, initial, delay_sprites)
			card.ability.Xmult = 2
			card.ability.x_mult = 2
			card.ability.extra = 3 -- 1/3 chance to break
		end,
	}, true)

	MP.ACTIVE_RULESET_OVERRIDES.standard_pack = {
		type = "booster",
		kind = "Standard",
	}

	-- Apply experimental standard pack override (no glass cards)
	SMODS.Booster:take_ownership_by_kind("Standard", {
		create_card = function(self, card, i)
			local enchantment_pool = {}

			-- Skip glass
			for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
				if v.key ~= "m_glass" then
					enchantment_pool[#enchantment_pool + 1] = v
				end
			end

			local ante_rng = MP.ante_based()
			local _edition = poll_edition("standard_edition" .. ante_rng, 2, true)
			local _seal = SMODS.poll_seal({ mod = 10, key = "stdseal" .. ante_rng })

			local newCard = create_playing_card({
				front = pseudorandom_element(G.P_CARDS, pseudoseed("stdset" .. ante_rng)),
				center = pseudorandom_element(enchantment_pool, pseudoseed("stdset" .. ante_rng)),
			}, G.pack_cards, true, i ~= 1, { G.C.SECONDARY_SET.Default })

			newCard:set_edition(_edition)
			newCard:set_seal(_seal)

			return newCard
		end,
	}, true)
end
