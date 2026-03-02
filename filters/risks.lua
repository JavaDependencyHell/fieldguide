function Para(el)
  local text = pandoc.utils.stringify(el)

  local map = {
    LOW = "\\riskLOW{}",
    MEDIUM = "\\riskMEDIUM{}",
    HIGH = "\\riskHIGH{}",
    CRITICAL = "\\riskCRITICAL{}"
  }

  for word, latex in pairs(map) do
    local pattern = "^%s*" .. word .. "%s+[—%-]"
    if text:match(pattern) then
      local rest = text:gsub("^%s*" .. word .. "%s+[—%-]%s*", "")
      return pandoc.Para({
        pandoc.RawInline("latex", latex),
        pandoc.Space(),
        pandoc.Str(rest)
      })
    end
  end
end