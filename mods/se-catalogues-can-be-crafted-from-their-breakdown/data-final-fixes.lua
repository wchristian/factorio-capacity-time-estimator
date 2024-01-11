local prototype_util = require('prototype.util')

local function get_recipe_results(recipe)
  if recipe.results then return recipe.results end

  if recipe.normal then return get_recipe_results(recipe.normal) end
  -- lets just say that expensive mode is currently not supported :)

  return {{type = "item", name = recipe.result, amount = recipe.result_count or 1}}
end

local function get_full_recipe_results(recipe)
  -- local results = table.deepcopy(get_recipe_results(recipe))
  local results = get_recipe_results(recipe)
  for i, result in pairs(results) do
    if result[1] and result[2] then
      results[i] = {type = "item", name = result[1], amount = result[2]}
    end
    result.type = result.type or "item"
  end

  return results
end

-- log(serpent.block(data.raw['recipe']))
-- error()

local recipes_for = {}
for _, recipe in pairs(data.raw['recipe']) do
  for _, result in pairs(get_full_recipe_results(recipe)) do
    if result.type == "item" then
      recipes_for[result.name] = recipes_for[result.name] or {}
      table.insert(recipes_for[result.name], recipe.name)
    end
  end
end

-- log(serpent.block(recipes_for))
-- error()

local function handle_catalogue(item_name)
  local recipe = data.raw['recipe'][item_name] -- assume the catalogue has the same recipe name as the item
  assert(recipe)
  assert(recipe.normal == nil)
  assert(recipe.expensive == nil)

  local clone = table.deepcopy(recipe)
  clone.localised_name = {"", {"item-name." .. clone.name}, " shortcut"}
  clone.name = clone.name .. '-shortcut'

  do -- lazy bastard-ify the icon
    if clone.icon == nil and clone.icons == nil then
      clone.icons = table.deepcopy(data.raw['item'][item_name].icons)
    end

    if clone.icons == nil then
      clone.icons = {{icon = clone.icon, icon_size = clone.icon_size}}
    end

    clone.icon = nil
    clone.icon_size = nil

    for _, icondata in ipairs(clone.icons) do
      icondata.scale = (icondata.scale or 1) * 0.3
    end

    table.insert(clone.icons, 1, {icon = "__base__/graphics/achievement/lazy-bastard.png", icon_size = 128, scale = 0.25})
  end

  -- clone.enabled = true
  clone.order = string.sub(data.raw['item'][item_name].order, 2):gsub("^", "b") -- a-1 -> b-1
  data:extend{clone}

  prototype_util.unlock_recipe_alongside(clone.name, recipe.name)

  if item_name ~= "se-astronomic-catalogue-1" then return end

  log(serpent.block( recipe ))

  for _, ingredient in ipairs(recipe.ingredients) do
    log(serpent.block( data.raw['recipe'][ingredient.name] ))
  end
  -- error()
end

for _, item in pairs(data.raw['item']) do
  if string.match(item.name, "-catalogue-") then
    log(item.name)
    handle_catalogue(item.name)
  end
end

-- handle_catalogue('se-astronomic-catalogue-1')

-- se-astronomic-catalogue-1
-- se-astronomic-catalogue-2
-- se-astronomic-catalogue-3
-- se-astronomic-catalogue-4
-- se-biological-catalogue-1
-- se-biological-catalogue-2
-- se-biological-catalogue-3
-- se-biological-catalogue-4
-- se-energy-catalogue-1
-- se-energy-catalogue-2
-- se-energy-catalogue-3
-- se-energy-catalogue-4
-- se-material-catalogue-1
-- se-material-catalogue-2
-- se-material-catalogue-3
-- se-material-catalogue-4
-- se-deep-catalogue-1
-- se-deep-catalogue-2
-- se-deep-catalogue-3
-- se-deep-catalogue-4
-- se-kr-matter-catalogue-1
-- se-kr-matter-catalogue-2

-- error()
