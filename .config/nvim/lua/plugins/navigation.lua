return {
	{
		"mrjones2014/smart-splits.nvim",
        opts = {
            at_edge = 'split',
        },
		keys = {
			{ "<C-h>",  function() require('smart-splits').move_cursor_left() end,     {} },
			{ "<C-j>",  function() require('smart-splits').move_cursor_down() end,     {} },
			{ "<C-k>",  function() require('smart-splits').move_cursor_up() end,       {} },
			{ "<C-l>",  function() require('smart-splits').move_cursor_right() end,    {} },
			{ "<C-\\>", function() require('smart-splits').move_cursor_previous() end, {} },
		},
		lazy = false,
	}
}
