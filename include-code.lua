function CodeBlock(el)
  if el.attributes['include'] then
    local filename = el.attributes['include']
    local snippet = el.attributes['snippet']

    local paths_to_try = {}

    if filename:sub(1,1) == "/" then
      -- Path relative to project root (e.g. /demos/...)
      local clean_filename = filename:sub(2)
      paths_to_try = {
        "../" .. clean_filename, -- If running from book/
        clean_filename           -- If running from root
      }
    else
      -- Relative path logic
      -- In Quarto, the filter might run on a temporary copy of the file.
      -- However, the original document path is often passed in PANDOC_SOURCE_FILE

      local source_file = PANDOC_SOURCE_FILE or ""
      local base_dir = source_file:match("(.*[/\\])") or ""

      paths_to_try = {
        base_dir .. filename,
        filename,
        "../" .. base_dir .. filename -- Sometimes needed if running from book/ but base_dir is relative to book/
      }

      -- Final attempt fallback logic from original script
      if not (io.open(paths_to_try[1], "r") or io.open(paths_to_try[2], "r") or io.open(paths_to_try[3], "r")) then
         if source_file:sub(1,3) == "../" then
             local path = source_file:sub(4):match("(.*[/\\])") or ""
             path = "../" .. path .. filename
             table.insert(paths_to_try, path)
         end
      end
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

    if not file then
      local source_info = PANDOC_SOURCE_FILE or "unknown"
      el.text = "ERROR: Could not open file " .. filename .. " (source_file=" .. source_info .. ")"
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
