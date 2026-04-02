local stringify = pandoc.utils.stringify

-- -------------------------------------------------
-- Style registry — 3-tier visual hierarchy
--
-- tier 1 (primary):   Bold box, colored left border, prominent label
--                     → SCENARIO, FIX, RISK, CONTROL
-- tier 2 (standard):  Light box, subtle border, inline label
--                     → EXAMPLE, EXPECT, ACTUAL, REALITY, WHY, CHECK
-- tier 3 (minimal):   No box — bold heading + plain text
--                     → RELATED, SCALES, TAKEAWAY, DIAGRAM, DOT, LOOK
-- tier "wild":        Special storytelling treatment
--                     → WILD
-- -------------------------------------------------

local STYLE = {
  -- Tier 1: high-visibility, action-oriented
  scenario = {
    label = "SCENARIO", tier = 1,
    bg = "black!4",           frame = "black!50",
    accent = "black!70",      css = "scn-scenario",
  },
  fix = {
    label = "FIX", tier = 1,
    bg = "green!6!white",     frame = "green!40!black",
    accent = "green!50!black", css = "scn-fix",
  },
  risk = {
    label = "RISK", tier = 1,
    bg = "red!6!white",       frame = "red!50!black",
    accent = "red!50!black",  css = "scn-risk",
  },
  control = {
    label = "CONTROL", tier = 1,
    bg = "teal!6!white",      frame = "teal!40!black",
    accent = "teal!50!black", css = "scn-control",
  },

  -- Tier 2: supporting detail
  example = {
    label = "EXAMPLE", tier = 2,
    bg = "black!2",           frame = "black!25",
    accent = "black!50",      css = "scn-example",
  },
  expect = {
    label = "EXPECT", tier = 2,
    bg = "blue!4!white",      frame = "blue!25!black",
    accent = "blue!40!black", css = "scn-expect",
  },
  actual = {
    label = "ACTUAL", tier = 2,
    bg = "violet!5!white",    frame = "violet!25!black",
    accent = "violet!40!black", css = "scn-actual",
  },
  reality = {
    label = "REALITY", tier = 2,
    bg = "violet!4!white",    frame = "violet!25!black",
    accent = "violet!40!black", css = "scn-reality",
  },
  why = {
    label = "WHY", tier = 2,
    bg = "black!2",           frame = "black!25",
    accent = "black!50",      css = "scn-why",
  },
  check = {
    label = "CHECK", tier = 2,
    bg = "black!2",           frame = "black!25",
    accent = "black!50",      css = "scn-check",
  },
  deterministic = {
    label = "CHECK", tier = 2,
    bg = "black!2",           frame = "black!25",
    accent = "black!50",      css = "scn-check",
  },

  -- Tier 3: lightweight — no box
  takeaway = {
    label = "TAKEAWAY", tier = 3,
    accent = "black!60",      css = "scn-takeaway",
  },
  related = {
    label = "RELATED", tier = 3,
    accent = "black!50",      css = "scn-related",
  },
  scales = {
    label = "AT SCALE", tier = 3,
    accent = "black!60",      css = "scn-scales",
  },
  diagram = {
    label = "DIAGRAM", tier = 3,
    accent = "black!50",      css = "scn-diagram",
  },
  dot = {
    label = "DOT", tier = 3,
    accent = "black!50",      css = "scn-dot",
  },
  look = {
    label = "LOOK FOR", tier = 3,
    accent = "black!50",      css = "scn-look",
  },

  -- Special: storytelling
  wild = {
    label = "SEEN IN THE WILD", tier = "wild",
    bg = "yellow!8!white",    frame = "yellow!30!black",
    accent = "yellow!45!black", css = "scn-wild",
  },
}

local DEFAULT_STYLE = {
  label = "NOTE", tier = 2,
  bg    = "black!2",
  frame = "black!25",
  accent = "black!50",
  css   = "scn-note",
}

-- -------------------------------------------------
-- Helpers
-- -------------------------------------------------

local function sanitize_kind(s)
  return s:lower():gsub("[^%w%-_]", "")
end

local function warn_unknown(kind, header_text)
  io.stderr:write(
    "[callout] Unknown token '! " .. kind ..
    "' in heading: \"" .. header_text .. "\"\n"
  )
end

local function get_style(kind, header_text)
  local st = STYLE[kind]
  if not st then
    warn_unknown(kind, header_text)
    st = DEFAULT_STYLE
  end
  return st
end

local function is_html(format)
  return format == "html" or format == "html5" or format == "html4"
end

local function is_latex(format)
  return format == "latex" or format == "pdf"
end

-- -------------------------------------------------
-- LaTeX emitters per tier
-- -------------------------------------------------

local function emit_latex_tier1(out, style, captured)
  -- Bold box: colored left border, tinted background, inline label at top
  table.insert(out, pandoc.RawBlock("latex",
    "\\begin{scnprimary}[scn accent={" .. style.accent ..
    "}, scn bg={" .. style.bg ..
    "}, scn frame={" .. style.frame .. "}]" ..
    "{" .. style.label .. "}"
  ))
  for _, b in ipairs(captured) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock("latex", "\\end{scnprimary}"))
end

local function emit_latex_tier2(out, style, captured)
  -- Standard box: thin frame, subtle background, small inline label
  table.insert(out, pandoc.RawBlock("latex",
    "\\begin{scnstandard}[scn accent={" .. style.accent ..
    "}, scn bg={" .. style.bg ..
    "}, scn frame={" .. style.frame .. "}]" ..
    "{" .. style.label .. "}"
  ))
  for _, b in ipairs(captured) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock("latex", "\\end{scnstandard}"))
end

local function emit_latex_tier3(out, style, captured)
  -- No box: just a styled label heading + content
  table.insert(out, pandoc.RawBlock("latex",
    "\\scnminimal{" .. style.accent .. "}{" .. style.label .. "}"
  ))
  for _, b in ipairs(captured) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock("latex",
    "\\vspace{0.6em}"
  ))
end

local function emit_latex_wild(out, style, captured)
  -- Storytelling box: distinct background, italic lead, rule separator
  table.insert(out, pandoc.RawBlock("latex",
    "\\begin{scnwild}[scn accent={" .. style.accent ..
    "}, scn bg={" .. style.bg ..
    "}, scn frame={" .. style.frame .. "}]" ..
    "{" .. style.label .. "}"
  ))
  for _, b in ipairs(captured) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock("latex", "\\end{scnwild}"))
end

-- -------------------------------------------------
-- HTML emitters per tier
-- -------------------------------------------------

local function emit_html_tier1(out, style, captured)
  table.insert(out, pandoc.RawBlock("html",
    '<div class="scn-callout scn-tier1 ' .. style.css .. '">' ..
    '<div class="scn-label" style="color:' ..
    (style.css == "scn-fix" and "#2d6a30" or
     style.css == "scn-risk" and "#a33" or
     style.css == "scn-control" and "#1a7a6a" or "#444") ..
    ';font-weight:700;font-size:0.8em;text-transform:uppercase;' ..
    'letter-spacing:0.08em;margin-bottom:0.4em;">' ..
    style.label .. '</div>'
  ))
  for _, b in ipairs(captured) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock("html", "</div>"))
end

local function emit_html_tier2(out, style, captured)
  table.insert(out, pandoc.RawBlock("html",
    '<div class="scn-callout scn-tier2 ' .. style.css .. '">' ..
    '<div class="scn-label" style="color:#666;font-weight:600;' ..
    'font-size:0.75em;text-transform:uppercase;letter-spacing:0.06em;' ..
    'margin-bottom:0.3em;">' .. style.label .. '</div>'
  ))
  for _, b in ipairs(captured) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock("html", "</div>"))
end

local function emit_html_tier3(out, style, captured)
  table.insert(out, pandoc.RawBlock("html",
    '<div class="scn-callout scn-tier3 ' .. style.css .. '">' ..
    '<div class="scn-label" style="color:#888;font-weight:700;' ..
    'font-size:0.7em;text-transform:uppercase;letter-spacing:0.06em;' ..
    'margin-bottom:0.2em;border-bottom:1px solid #ddd;' ..
    'padding-bottom:0.2em;">' .. style.label .. '</div>'
  ))
  for _, b in ipairs(captured) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock("html", "</div>"))
end

local function emit_html_wild(out, style, captured)
  table.insert(out, pandoc.RawBlock("html",
    '<div class="scn-callout scn-wild">' ..
    '<div class="scn-label" style="color:#8a6d00;font-weight:700;' ..
    'font-size:0.8em;text-transform:uppercase;letter-spacing:0.08em;' ..
    'margin-bottom:0.4em;font-style:italic;">' ..
    style.label .. '</div>'
  ))
  for _, b in ipairs(captured) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock("html", "</div>"))
end

-- -------------------------------------------------
-- Main transform
-- -------------------------------------------------

function Pandoc(doc)
  local out, blocks, i = {}, doc.blocks, 1
  local fmt = FORMAT or ""

  while i <= #blocks do
    local blk = blocks[i]
    local processed = false

    if blk.t == "Header" then
      local full = stringify(blk.content)
      local bang, rest = full:match("^%s*(!)%s*(.*)$")

      if bang then
        local first, remainder = rest:match("^(%S+)%s*(.*)$")

        if first then
          local kind = sanitize_kind(first)
          local style = get_style(kind, full)

          -- Capture following blocks
          local captured = {}

          if remainder and remainder ~= "" then
            table.insert(
              captured,
              pandoc.Header(blk.level, pandoc.Inlines(remainder))
            )
          end

          local j = i + 1
          while j <= #blocks do
            local nb = blocks[j]
            if nb.t == "Header" and nb.level <= blk.level then break end
            table.insert(captured, nb)
            j = j + 1
          end

          -- Emit format-specific output based on tier
          if is_html(fmt) then
            if style.tier == 1 then
              emit_html_tier1(out, style, captured)
            elseif style.tier == "wild" then
              emit_html_wild(out, style, captured)
            elseif style.tier == 3 then
              emit_html_tier3(out, style, captured)
            else
              emit_html_tier2(out, style, captured)
            end
          elseif is_latex(fmt) then
            if style.tier == 1 then
              emit_latex_tier1(out, style, captured)
            elseif style.tier == "wild" then
              emit_latex_wild(out, style, captured)
            elseif style.tier == 3 then
              emit_latex_tier3(out, style, captured)
            else
              emit_latex_tier2(out, style, captured)
            end
          else
            -- Fallback: legacy scncallout for other formats
            table.insert(out, pandoc.RawBlock("latex",
              "\\begin{scncallout}[scn label={" .. style.label ..
              "}, scn bg={" .. (style.bg or "black!2") ..
              "}, scn frame={" .. (style.frame or "black!40") .. "}]"
            ))
            for _, b in ipairs(captured) do table.insert(out, b) end
            table.insert(out, pandoc.RawBlock("latex", "\\end{scncallout}"))
          end

          i = j
          processed = true
        end
      end
    end

    if not processed then
      table.insert(out, blk)
      i = i + 1
    end
  end

  return pandoc.Pandoc(out, doc.meta)
end
