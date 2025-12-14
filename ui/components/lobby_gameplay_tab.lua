local ECONOMIC_TIMER_PRESETS = {
	{
		key = "standard",
		label = "Standard: 30s hand / 90s shop+blind",
		hand = 30,
		shop = 90,
	},
	{
		key = "fast",
		label = "Rapid: 10s hand / 45s shop+blind",
		hand = 10,
		shop = 45,
	},
	{
		key = "relaxed",
		label = "Relaxed: 60s hand / 150s shop+blind",
		hand = 60,
		shop = 150,
	},
}

local ECONOMIC_TIMER_PRESET_BY_LABEL = {}
local ECONOMIC_TIMER_PRESET_INDEX_BY_KEY = {}
for i, preset in ipairs(ECONOMIC_TIMER_PRESETS) do
	ECONOMIC_TIMER_PRESET_BY_LABEL[preset.label] = preset
	ECONOMIC_TIMER_PRESET_INDEX_BY_KEY[preset.key] = i
end

local function apply_economic_timer_preset(preset)
	if not preset then return end
	MP.LOBBY.config.economic_timer_mode = preset.key
	MP.LOBBY.config.economic_timer_hand_threshold = preset.hand
	MP.LOBBY.config.economic_timer_shop_threshold = preset.shop
end

G.FUNCS.toggle_economic_timer = function()
	if MP.LOBBY.config.economic_timer then
		MP.LOBBY.config.timer = false
		local preset =
			ECONOMIC_TIMER_PRESET_BY_LABEL[ECONOMIC_TIMER_PRESETS[1].label]
			or ECONOMIC_TIMER_PRESETS[1]
		if MP.LOBBY.config.economic_timer_mode then
			local idx = ECONOMIC_TIMER_PRESET_INDEX_BY_KEY[MP.LOBBY.config.economic_timer_mode]
			preset = ECONOMIC_TIMER_PRESETS[idx] or preset
		end
		apply_economic_timer_preset(preset)
	end
	send_lobby_options()
end

G.FUNCS.change_economic_timer_mode = function(args)
	if not args or not args.to_val then return end
	local preset = ECONOMIC_TIMER_PRESET_BY_LABEL[args.to_val] or ECONOMIC_TIMER_PRESETS[1]
	apply_economic_timer_preset(preset)
	MP.LOBBY.config.economic_timer = true
	MP.LOBBY.config.timer = false
	send_lobby_options()
end

function MP.UI.create_gameplay_options_tab()
	local economic_timer_labels = {}
	for i, preset in ipairs(ECONOMIC_TIMER_PRESETS) do
		economic_timer_labels[i] = preset.label
	end
	local economic_timer_mode_index = ECONOMIC_TIMER_PRESET_INDEX_BY_KEY[MP.LOBBY.config.economic_timer_mode]
		or ECONOMIC_TIMER_PRESET_INDEX_BY_KEY["standard"]
		or 1

	return {
		n = G.UIT.ROOT,
		config = {
			emboss = 0.05,
			minh = 3,
			r = 0.1,
			minw = 10,
			align = "tm",
			padding = 0.2,
			colour = G.C.BLACK,
		},
		nodes = {
			create_lobby_option_toggle("gold_on_life_loss_toggle", "b_opts_cb_money", "gold_on_life_loss"),
			create_lobby_option_toggle(
				"no_gold_on_round_loss_toggle",
				"b_opts_no_gold_on_loss",
				"no_gold_on_round_loss"
			),
			create_lobby_option_toggle("death_on_round_loss_toggle", "b_opts_death_on_loss", "death_on_round_loss"),
			create_lobby_option_toggle("timer_toggle", "b_opts_timer", "timer"),
			create_lobby_option_toggle(
				"economic_timer_toggle",
				"k_opts_experimental_timer",
				"economic_timer",
				"toggle_economic_timer"
			),
			create_lobby_option_cycle(
				"timer_mode_option",
				"k_opts_timer_mode",
				0.85,
				economic_timer_labels,
				economic_timer_mode_index,
				"change_economic_timer_mode"
			),
		},
	}
end
