local function is_html(format)
  return format == "html" or format == "html5" or format == "html4"
end

function Para(el)
  local text = pandoc.utils.stringify(el)
  local fmt = FORMAT or ""

  local map_latex = {
    LOW = "\\riskLOW{}",
    MEDIUM = "\\riskMEDIUM{}",
    HIGH = "\\riskHIGH{}",
    CRITICAL = "\\riskCRITICAL{}"
  }

  local map_html = {
    LOW      = '<span class="risk-badge risk-low">LOW</span>',
    MEDIUM   = '<span class="risk-badge risk-medium">MEDIUM</span>',
    HIGH     = '<span class="risk-badge risk-high">HIGH</span>',
    CRITICAL = '<span class="risk-badge risk-critical">CRITICAL</span>'
  }

  for word, _ in pairs(map_latex) do
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
      if is_html(fmt) then
        return pandoc.Para({
          pandoc.RawInline("html", map_html[word]),
          pandoc.Space(),
          pandoc.Str(rest)
        })
      else
        return pandoc.Para({
          pandoc.RawInline("latex", map_latex[word]),
          pandoc.Space(),
          pandoc.Str(rest)
        })
      end
    end
  end
end

-- Also handle plain text in other contexts (e.g., inside lists)
function Str(el)
  local fmt = FORMAT or ""

  local map_latex = {
    LOW = "\\riskLOW{}",
    MEDIUM = "\\riskMEDIUM{}",
    HIGH = "\\riskHIGH{}",
    CRITICAL = "\\riskCRITICAL{}"
  }

  local map_html = {
    LOW      = '<span class="risk-badge risk-low">LOW</span>',
    MEDIUM   = '<span class="risk-badge risk-medium">MEDIUM</span>',
    HIGH     = '<span class="risk-badge risk-high">HIGH</span>',
    CRITICAL = '<span class="risk-badge risk-critical">CRITICAL</span>'
  }

  if map_latex[el.text] then
    if is_html(fmt) then
      return pandoc.RawInline("html", map_html[el.text])
    else
      return pandoc.RawInline("latex", map_latex[el.text])
    end
  end
end
