needs_select_tabset = false;

function Div(el)
  if el.classes:includes("panel-select") then
    needs_select_tabset = true
  end
  if needs_select_tabset then
    local tabs, level = parse_tabset_contents(el);
    local label = el.attr.attributes["option-label"]
    return render_tabset(el, tabs, level, label)
  end
end

function Meta()
  if needs_select_tabset then
    quarto.doc.add_html_dependency({
      name = 'select-tabset',
      scripts = { { path = 'resources/select-tabset.js', afterBody = true } },
      stylesheets = { 'resources/select-tabset.css' }
    })
  end
end

function get_headings(div, level, tabsetid)
  local headings = div.content:filter(function(el) return el.t == "Header" and el.level == level end)
  local ids = headings:map(
    function(heading)
      local name = pandoc.utils.stringify(heading);
      local value = tabsetid .. '-' .. name:gsub("%s", "-"):lower();
      return { name = name, value = value }
    end
  )
  return ids
end

function create_select(tab_ids, label)
  local options = tab_ids:map(
    function(tab_id)
      local option = pandoc.RawBlock('html',
        '<option value="' .. tab_id.value .. '">' .. tab_id.name .. '</option>')
      return option
    end
  )
  local label_text = label and label or "Select an option";
  quarto.log.output(label_text)
  return pandoc.Div({
    pandoc.RawInline('html', '<div class="d-flex align-items-center gap-3 mb-2">'),
    pandoc.RawInline('html', [[
      <label for="tabSelect" class="form-label fw-bolder mb-0">
        ]] .. label_text .. [[
      </label>
    ]]),
    pandoc.RawInline('html', '<select class="form-select w-auto flex-grow-1">'),
    pandoc.Div(options),
    pandoc.RawInline('html', '</select>'),
    pandoc.RawInline('html', '</div>')
  })
end

function parse_tabset_contents(div)
  local heading = div.content:find_if(function(el) return el.t == "Header" end)
  if heading ~= nil then
    -- note the level, then build tab buckets for content after these levels
    local level = heading.level
    local tabs = pandoc.List()
    local tab = nil
    for i = 1, #div.content do
      local el = div.content[i]
      if el.t == "Header" and el.level == level then
        tab = quarto.Tab({ title = el.content })
        tabs:insert(tab)
      elseif tab ~= nil then
        tab.content:insert(el)
      end
    end
    return tabs, level
  else
    return nil
  end
end

local tabsetidx = 1

function render_tabset(el, tabs, level, label)
  -- create a unique id for the tabset
  local tabsetid = "tabset-" .. tabsetidx
  tabsetidx = tabsetidx + 1

  local tab_ids = get_headings(el, level, tabsetid)

  -- init tab navigation
  local select = create_select(tab_ids, label)

  -- init tab panes
  local panes = pandoc.Div({}, el.attr)
  panes.attr.classes = el.attr.classes:map(function(class)
    if class == "panel-select" then
      return "tab-content"
    else
      return class
    end
  end)

  -- populate
  for i = 1, #tabs do
    -- alias tab and heading
    local tab = tabs[i]

    -- tab id
    local tabid = tabsetid .. "-" .. i

    -- pane
    local pane = pandoc.Div({})
    pane.attr.identifier = tab_ids[i].value
    pane.attr.classes = { "tab-pane", i == 1 and "active" or nil }
    pane.content:extend(tab.content)
    panes.content:insert(pane)
  end
  -- end tab navigation

  local tabset = pandoc.Div({
    select,
    panes
  })
  tabset.attr.identifier = tabsetid
  tabset.attr.classes = { "select-tabset", "mb-3", "p-2", "border", "border-light-subtle", "rounded" }
  return tabset
end
