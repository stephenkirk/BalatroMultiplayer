local function create_player_info_row(player, player_type, text_scale)
	if not player or not player.username then return nil end

	return MP.UI.UTILS.create_row({ padding = 0.1, align = "cm" }, {
		MP.UI.UTILS.create_text_node(nil, {
			ref_table = player,
			ref_value = "username",
			scale = text_scale * 0.8,
			colour = G.C.UI.TEXT_LIGHT,
		}),
		MP.UI.UTILS.create_blank(0.1, 0.1),
		player.hash and UIBox_button({
			id = player_type .. "_hash",
			button = "view_" .. player_type .. "_hash",
			label = { player.hash },
			minw = 0.75,
			minh = 0.3,
			scale = 0.25,
			shadow = false,
			colour = G.C.PURPLE,
			col = true,
		}) or nil,
	})
end

local function create_gamemode_indicator(text_scale)
	local gamemode_key = MP.LOBBY.config and MP.LOBBY.config.gamemode
	local ruleset_key = MP.LOBBY.config and MP.LOBBY.config.ruleset

	-- Strip "gamemode_mp_" (12 chars) and "ruleset_mp_" (11 chars) prefixes to get localization keys
	local gamemode_name = gamemode_key and localize("k_" .. string.sub(gamemode_key, 13)) or nil
	local ruleset_name = ruleset_key and localize("k_" .. string.sub(ruleset_key, 12)) or nil

	if not gamemode_name and not ruleset_name then return nil end

	local parts = {}
	if ruleset_name then parts[#parts + 1] = ruleset_name end
	if gamemode_name then parts[#parts + 1] = gamemode_name end
	local label = table.concat(parts, " \xc2\xb7 ")

	return MP.UI.UTILS.create_row({ align = "cm", padding = 0.1 }, {
		MP.UI.UTILS.create_text_node(label, {
			scale = text_scale * 0.7,
			colour = G.C.ETERNAL,
		}),
	})
end

function MP.UI.create_players_section(text_scale)
	return MP.UI.UTILS.create_column({ align = "tm", minw = 2.65 }, {
		create_gamemode_indicator(text_scale),
		MP.UI.UTILS.create_row({ align = "cm", padding = 0.15 }, {
			MP.UI.UTILS.create_text_node(localize("k_connect_player"), {
				scale = text_scale * 0.8,
				colour = G.C.UI.TEXT_LIGHT,
			}),
		}),
		create_player_info_row(MP.LOBBY.host, "host", text_scale),
		create_player_info_row(MP.LOBBY.guest, "guest", text_scale),
	})
end
