-- Cache for snippet-based file lookups (avoids repeated 'find' calls)
local _snippet_cache = {}

-- Fallback: search project tree for a file with the given name that contains
-- the requested snippet tag.  Results are cached so 'find' only runs once per
-- unique filename.
local function find_file_by_snippet(project_dir, filename, snippet)
  if not snippet or snippet == "" then return nil end

  local cache_key = filename .. "::" .. snippet
  if _snippet_cache[cache_key] then
    return _snippet_cache[cache_key]
  end

  -- Build a list of candidate paths (all files matching filename under project)
  -- Exclude build/ and .quarto/ directories
  local search_root = (project_dir ~= "") and project_dir or "."
  local cmd = 'find "' .. search_root .. '" -name "' .. filename
            .. '" -not -path "*/build/*" -not -path "*/.quarto/*" -type f 2>/dev/null'
  local handle = io.popen(cmd)
  if not handle then return nil end

  for found_path in handle:lines() do
    local f = io.open(found_path, "r")
    if f then
      local content = f:read("*all")
      f:close()
      if content:find("tag::" .. snippet, 1, true) then
        _snippet_cache[cache_key] = found_path
        handle:close()
        return found_path
      end
    end
  end
  handle:close()
  return nil
end

function CodeBlock(el)
  if el.classes:includes('xml') then
    if FORMAT:match('latex') then
      local res = CodeBlock_Original(el)
      if type(res) == "table" then
        table.insert(res, 1, pandoc.RawBlock('latex', '{\\small'))
        table.insert(res, pandoc.RawBlock('latex', '}'))
        return res
      else
        return {
          pandoc.RawBlock('latex', '{\\small'),
          res,
          pandoc.RawBlock('latex', '}')
        }
      end
    elseif FORMAT:match('html') then
      el.attributes['style'] = (el.attributes['style'] or "") .. " font-size: 0.8em;"
    end
  end
  return CodeBlock_Original(el)
end

function CodeBlock_Original(el)
  if el.attributes['include'] then
    local filename = el.attributes['include']
    local snippet = el.attributes['snippet']

    local paths_to_try = {}

    -- Gather source file reference
    local source_file = ""

    -- 1. Try Quarto's own API first
    if quarto and quarto.doc and quarto.doc.input_file then
      local qf = quarto.doc.input_file
      if type(qf) == "function" then
        local ok, val = pcall(qf)
        if ok and val and val ~= "" then source_file = val end
      elseif type(qf) == "string" and qf ~= "" then
        source_file = qf
      end
    end

    -- 2. Fall back to standard Pandoc source file
    if source_file == "" and PANDOC_SOURCE_FILE and tostring(PANDOC_SOURCE_FILE) ~= "" then
      source_file = tostring(PANDOC_SOURCE_FILE)
    end

    -- 3. Project directory from environment
    local project_dir = os.getenv("QUARTO_PROJECT_DIR") or ""

    if filename:sub(1,1) == "/" then
      -- Absolute project path (e.g. /demos/...)
      local clean_filename = filename:sub(2)
      paths_to_try = {
        clean_filename,
        "../" .. clean_filename,
      }
      if project_dir ~= "" then
        table.insert(paths_to_try, project_dir .. "/" .. clean_filename)
      end
    else
      -- Relative path: resolve against the source file's directory
      local base_dir = source_file:match("(.*[/\\])") or ""

      if base_dir ~= "" then
        table.insert(paths_to_try, base_dir .. filename)
      end

      if source_file:sub(1,3) == "../" then
        local inner = source_file:sub(4):match("(.*[/\\])") or ""
        table.insert(paths_to_try, "../" .. inner .. filename)
        table.insert(paths_to_try, inner .. filename)
      end

      if project_dir ~= "" and source_file:sub(1,1) == "/" then
        local rel = source_file:sub(#project_dir + 2)
        local rel_dir = rel:match("(.*[/\\])") or ""
        table.insert(paths_to_try, rel_dir .. filename)
      end

      if base_dir ~= "" then
        table.insert(paths_to_try, "../" .. base_dir .. filename)
      end

      table.insert(paths_to_try, filename)
    end

    local file = nil
    local final_path = ""

    for _, path in ipairs(paths_to_try) do
      file = io.open(path, "r")
      if file then
        final_path = path
        break
      end
    end

    -- Fallback: search project tree for a file containing the snippet tag.
    -- This handles the case where Quarto profiles report PANDOC_SOURCE_FILE
    -- as index.qmd instead of the actual chapter file.
    if not file then
      local found = find_file_by_snippet(project_dir, filename, snippet)
      if found then
        file = io.open(found, "r")
        if file then final_path = found end
      end
    end

    if not file then
      io.stderr:write("[include-code] FAILED: " .. filename
        .. " (snippet=" .. (snippet or "nil")
        .. ", source=" .. source_file .. ")\n")
      el.text = "ERROR: Could not open file " .. filename
      return el
    end

    local content = file:read("*all")
    file:close()

    if snippet then
      -- Very flexible pattern to find the snippet
      local escaped_snippet = snippet:gsub("[%-%.%+%*%?%^%$%(%)%%]", "%%%1")
      -- Match between tag::name[] and end::name[]
      -- We want to capture everything between them, but avoid capturing the comment characters of the end tag.
      local pattern = "tag::" .. escaped_snippet .. "%[%]\r?\n?(.-)%s*//%s*end::" .. escaped_snippet .. "%[%]"

      local match = content:match(pattern)

      if not match then
        -- Try with # for Maven/other files
        pattern = "tag::" .. escaped_snippet .. "%[%]\r?\n?(.-)%s*#%s*end::" .. escaped_snippet .. "%[%]"
        match = content:match(pattern)
      end

      if not match then
        -- Try with XML/HTML comments <!-- ... -->
        pattern = "<!%-%-%s*tag::" .. escaped_snippet .. "%[%]%s*%-%->\r?\n?(.-)%s*<!%-%-%s*end::" .. escaped_snippet .. "%[%]%s*%-%->"
        match = content:match(pattern)
      end

      if not match then
        -- Generic fallback
        pattern = "tag::" .. escaped_snippet .. "%[%]\r?\n?(.-)end::" .. escaped_snippet .. "%[%]"
        match = content:match(pattern)
      end

      if match then
        -- Remove the comment prefix from the match if it's there on every line?
        -- Usually we just want the content between the tags.
        match = match:gsub("^%s*\r?\n", ""):gsub("\r?\n%s*$", "")
        el.text = match
      else
        el.text = "ERROR: Snippet '" .. snippet .. "' not found in " .. final_path
      end
    else
      el.text = content
    end
  end
  return el
end

function Div(el)
  if el.classes:includes('scenario') then
    if FORMAT:match('latex') then
      return {
        pandoc.RawBlock('latex', '\\begin{scenario}'),
        el,
        pandoc.RawBlock('latex', '\\end{scenario}')
      }
    elseif FORMAT:match('html') then
      el.attributes['style'] = 'border-left: 1.2pt solid black; padding-left: 6pt; margin-left: 0;'
      return el
    end
  elseif el.classes:includes('calloutbox') then
    if FORMAT:match('latex') then
      return {
        pandoc.RawBlock('latex', '\\begin{calloutbox}'),
        el,
        pandoc.RawBlock('latex', '\\end{calloutbox}')
      }
    elseif FORMAT:match('html') then
       el.attributes['style'] = 'background-color: #f7f7f7; border: 0.3pt solid #666; padding: 4pt; border-radius: 2pt;'
       return el
    end
  end
  return el
end
