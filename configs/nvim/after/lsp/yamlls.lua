return {
	settings = {
		yaml = {
			schemaStore = {
				enable = false,
				url = "",
			},
			schemas = function()
				local ok, schemas = pcall(require("schemastore").json.schemas())
				if ok then
					return schemas
				else
					return nil
				end
			end,
		},
	},
}
