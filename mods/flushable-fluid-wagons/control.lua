local _global = {player_should_open = {}}

script.on_event('open-fluid-wagon', function(event)
  local player = game.get_player(event.player_index)

  local entity = player.selected
  if entity == nil then return end
  if entity.type ~= 'fluid-wagon' then return end

  local fluid = entity.fluidbox[1]
  -- if fluid == nil then return end -- empty fluid wagon

  game.print(entity.name)

  local tank = entity.surface.create_entity{
    name = entity.name .. '-flushable',
    force = entity.force,
    position = entity.position,
  }

  tank.destructible = false
  if fluid then
    tank.insert_fluid(fluid)
  end

  _global.player_should_open[player.index] = tank

  local coin = {name = "coin", count = 1}
  if player.get_main_inventory().insert(coin) then
    player.get_main_inventory().remove(coin)
  end
end)

-- script.on_event(defines.events.on_gui_opened, function(event)
--   log(event.gui_type)
--   -- log(event.entity)
--   -- log(event.equipment)
--   if event.entity then log(event.entity.name) end
-- end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
  local player = game.get_player(event.player_index)

  local tank = _global.player_should_open[player.index]
  if tank == nil then return end
  _global.player_should_open[player.index] = nil
  player.opened = tank

  local root = player.gui.relative[tank.name]
  if root == nil then
    root = player.gui.relative.add{
      type= "frame",
      name = tank.name,
      anchor = {gui = defines.relative_gui_type.storage_tank_gui, position = defines.relative_gui_position.top},
      -- style = 'invisible_frame',
      -- direction="vertical",
      -- tags={unit_number=struct.unit_number} -- store unit_number in tag
    }
  end

  root.style.width = 448
  root.style.horizontal_align = 'center'
  -- root.style.top_padding = -50

  local sprite = root.add{
    type = 'sprite',
    sprite = 'entity/fluid-wagon',
  }

  sprite.style.bottom_margin = -50
  sprite.bring_to_front()
end)
