local stringify = pandoc.utils.stringify

-- -------------------------------------------------
-- Style registry (single source of truth)
-- -------------------------------------------------

local STYLE = {
  scenario = { label = "SCENARIO", bg = "black!2",        frame = "black!40",  css = "scn-scenario" },
  example  = { label = "EXAMPLE",  bg = "black!1",        frame = "black!30",  css = "scn-example"  },
  expect   = { label = "EXPECT",   bg = "blue!3!white",   frame = "black!35",  css = "scn-expect"   },
  actual   = { label = "ACTUAL",   bg = "blue!2!white",   frame = "black!35",  css = "scn-actual"   },
  reality  = { label = "REALITY",  bg = "violet!3!white", frame = "black!35",  css = "scn-reality"  },
  why      = { label = "WHY",      bg = "black!2",        frame = "black!40",  css = "scn-why"      },
  fix      = { label = "FIX",      bg = "orange!4!white", frame = "black!35",  css = "scn-fix"      },
  risk     = { label = "RISK",     bg = "red!5!white",    frame = "black!40",  css = "scn-risk"     },
  control  = { label = "CONTROL",  bg = "green!4!white",  frame = "black!35",  css = "scn-control"  },
  check    = { label = "CHECK",    bg = "black!2",        frame = "black!40",  css = "scn-check"    },
  look     = { label = "LOOK",     bg = "black!1",        frame = "black!30",  css = "scn-look"     },
  takeaway = { label = "TAKEAWAY", bg = "black!2",        frame = "black!40",  css = "scn-takeaway" },
  wild     = { label = "WILD",     bg = "yellow!6!white", frame = "black!40",  css = "scn-wild"     },
  related  = { label = "RELATED",  bg = "black!1",        frame = "black!30",  css = "scn-related"  },
  scales   = { label = "SCALES",   bg = "black!2",        frame = "black!40",  css = "scn-scales"   },
  diagram  = { label = "DIAGRAM",  bg = "black!1",        frame = "black!30",  css = "scn-diagram"  },
  dot      = { label = "DOT",      bg = "black!1",        frame = "black!30",  css = "scn-dot"      },
  deterministic = { label = "CHECK", bg = "black!2",      frame = "black!40",  css = "scn-check"    },
}

local DEFAULT_STYLE = {
  label = "NOTE",
  bg    = "black!2",
  frame = "black!40",
  css   = "scn-note"
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
-- Main transform
-- -------------------------------------------------

function Pandoc(doc)
  local out, blocks, i = {}, doc.blocks, 1
  local fmt = FORMAT or ""

  while i <= #blocks do
    local blk = blocks[i]
    local processed = false

    -- Only process headings
    if blk.t == "Header" then
      local full = stringify(blk.content)

      -- opt-in marker
      local bang, rest = full:match("^%s*(!)%s*(.*)$")

      if bang then
        local first, remainder = rest:match("^(%S+)%s*(.*)$")

        if first then
          local kind = sanitize_kind(first)
          local style = get_style(kind, full)

          -- ------------------------------------------
          -- Capture following blocks
          -- ------------------------------------------

          local captured = {}

          -- Preserve visible title if present
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

          -- ------------------------------------------
          -- Emit format-specific output
          -- ------------------------------------------

          if is_html(fmt) then
            -- HTML: div with CSS class + data attribute for label
            table.insert(out,
              pandoc.RawBlock(
                "html",
                '<div class="scn-callout ' .. style.css ..
                '" data-label="' .. style.label .. '">'
              )
            )

            for _, b in ipairs(captured) do
              table.insert(out, b)
            end

            table.insert(out,
              pandoc.RawBlock("html", "</div>")
            )
          else
            -- LaTeX: tcolorbox
            table.insert(out,
              pandoc.RawBlock(
                "latex",
                "\\begin{scncallout}[scn label={" .. style.label ..
                "}, scn bg={" .. style.bg ..
                "}, scn frame={" .. style.frame .. "}]"
              )
            )

            for _, b in ipairs(captured) do
              table.insert(out, b)
            end

            table.insert(out,
              pandoc.RawBlock("latex", "\\end{scncallout}")
            )
          end

          i = j
          processed = true
        end
      end
    end

    if not processed then
      -- default passthrough
      table.insert(out, blk)
      i = i + 1
    end
  end

  return pandoc.Pandoc(out, doc.meta)
end
