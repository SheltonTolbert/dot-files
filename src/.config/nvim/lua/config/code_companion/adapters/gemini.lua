local gemini = function()
  return require("codecompanion.adapters").extend(
    "gemini",
    {
      env = {
        api_key = "cmd:echo $GEMINI_API_TOKEN"
      }
    }
  )
end

return gemini
