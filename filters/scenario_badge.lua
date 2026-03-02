-- -------------------------------------------------
-- Convert S<number>[punct] into scenario badges
-- Handles: S1,  S10:  S2.  S3)  S4]  etc.
-- -------------------------------------------------

function Str(el)
  -- Capture:
  --  1) digits after S
  --  2) optional trailing punctuation (one of , : ; . ) ] })
  local num, punct = el.text:match("^S(%d+)([,:;%.%)]?[%]%}%)]?)$")

  -- The above pattern supports:
  -- - no punctuation
  -- - one punctuation char , : ; .
  -- - optionally followed by a closing bracket/brace/paren
  -- Examples: "S1," "S10:" "S2." "S3)" "S4]," "S5})"
  if num then
    local out = { pandoc.RawInline("latex", "\\scnref{" .. num .. "}") }
    if punct and punct ~= "" then
      table.insert(out, pandoc.Str(punct))
    end
    return out
  end

  -- Also handle cases like "S1," where punctuation is a single char only
  -- (covered above), otherwise leave unchanged
  return nil
end