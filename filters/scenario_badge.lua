-- -------------------------------------------------
-- Convert tool-prefixed scenario references into badges
--
-- Supported patterns:
--   MS1  MS10  GS3  SB7  (tool-specific)
--   S1   S10              (legacy, still supported)
--
-- Trailing punctuation is preserved: MS1, GS3: SB7.
-- -------------------------------------------------

local function is_html(format)
  return format == "html" or format == "html5" or format == "html4"
end

-- Map prefix to display label
local PREFIX_MAP = {
  MS = "MS",   -- Maven
  GS = "GS",   -- Gradle
  SB = "SB",   -- SBT
  S  = "S",    -- Legacy / generic
}

function Str(el)
  -- Match: optional tool prefix (MS, GS, SB) or bare S, then digits, then optional punctuation
  local prefix, num, punct = el.text:match("^(MS)(%d+)([,:;%.%)]?[%]%}%)]?)$")
  if not prefix then
    prefix, num, punct = el.text:match("^(GS)(%d+)([,:;%.%)]?[%]%}%)]?)$")
  end
  if not prefix then
    prefix, num, punct = el.text:match("^(SB)(%d+)([,:;%.%)]?[%]%}%)]?)$")
  end
  if not prefix then
    prefix, num, punct = el.text:match("^(S)(%d+)([,:;%.%)]?[%]%}%)]?)$")
  end

  if prefix and num then
    local label = PREFIX_MAP[prefix] or prefix
    local display = label .. num
    local fmt = FORMAT or ""

    if is_html(fmt) then
      local out = { pandoc.RawInline("html", '<span class="scn-badge">' .. display .. '</span>') }
      if punct and punct ~= "" then
        table.insert(out, pandoc.Str(punct))
      end
      return out
    else
      local out = { pandoc.RawInline("latex", "\\scnref{" .. display .. "}") }
      if punct and punct ~= "" then
        table.insert(out, pandoc.Str(punct))
      end
      return out
    end
  end

  return nil
end
