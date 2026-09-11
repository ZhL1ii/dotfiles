return {
	"rmagatti/auto-session",
	lazy = false,
	opts = {
		auto_save = true,
		auto_restore = true,
		auto_create = true,

		-- 避免在home\根目录\下载目录这类泛目录里乱存session
		suppressed_dirs = {
			"~/",
			"~/Downloads/",
			"/",
		},

		bypass_save_filetype = {
			"alpha",
			"dashboard",
		},
	},
}
