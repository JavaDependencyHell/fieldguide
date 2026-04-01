-- -------------------------------------------------
-- Convert S<number>[punct] into scenario badges
-- Handles: S1,  S10:  S2.  S3)  S4]  etc.
-- -------------------------------------------------

local function is_html(format)
  return format == "html" or format == "html5" or format == "html4"
end

function Str(el)
  -- Capture:
  --  1) digits after S
  --  2) optional trailing punctuation (one of , : ; . ) ] })
  local num, punct = el.text:match("^S(%d+)([,:;%.%)]?[%]%}%)]?)$")

  if num then
    local fmt = FORMAT or ""

    if is_html(fmt) then
      local out = { pandoc.RawInline("html", '<span class="scn-badge">S' .. num .. '</span>') }
      if punct and punct ~= "" then
        table.insert(out, pandoc.Str(punct))
      end
      return out
    else
      local out = { pandoc.RawInline("latex", "\\scnref{" .. num .. "}") }
      if punct and punct ~= "" then
        table.insert(out, pandoc.Str(punct))
      end
      return out
    end
  end

  return nil
end
