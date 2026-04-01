function Para(el)
  local text = pandoc.utils.stringify(el)

  local map = {
    LOW = "\\riskLOW{}",
    MEDIUM = "\\riskMEDIUM{}",
    HIGH = "\\riskHIGH{}",
    CRITICAL = "\\riskCRITICAL{}"
  }

  for word, latex in pairs(map) do
    -- We want to match:
    -- 1. "^LOW —" (Standard)
    -- 2. "^* LOW " (Markdown bullet)
    -- 3. "^LOW " (Simple start)

    local matched = false
    local rest = ""

    if text:match("^%s*" .. word .. "%s+[—%-]") then
      rest = text:gsub("^%s*" .. word .. "%s+[—%-]%s*", "")
      matched = true
    elseif text:match("^%s*[*]%s*" .. word .. "%s+") then
      rest = text:gsub("^%s*[*]%s*" .. word .. "%s+", "")
      matched = true
    elseif text:match("^%s*" .. word .. "%s+") then
      rest = text:gsub("^%s*" .. word .. "%s+", "")
      matched = true
    end

    if matched then
      return pandoc.Para({
        pandoc.RawInline("latex", latex),
        pandoc.Space(),
        pandoc.Str(rest)
      })
    end
  end
end

-- Also handle plain text in other contexts (e.g., inside lists)
function Str(el)
  local map = {
    LOW = "\\riskLOW{}",
    MEDIUM = "\\riskMEDIUM{}",
    HIGH = "\\riskHIGH{}",
    CRITICAL = "\\riskCRITICAL{}"
  }
  if map[el.text] then
    return pandoc.RawInline("latex", map[el.text])
  end
end