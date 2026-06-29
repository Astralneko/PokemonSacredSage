# Custom Weather Plugin - Documentation

A modular plugin for creating custom weather conditions with battle effects, map assignment, and overworld visuals.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Creating a New Weather Type](#creating-a-new-weather-type)
3. [Weather Graphics](#weather-graphics)
4. [Battle Effects](#battle-effects)
5. [Assigning Weather to Maps](#assigning-weather-to-maps)
6. [Assigning Weather to Battles](#assigning-weather-to-battles)
7. [API Reference](#api-reference)
8. [Examples](#examples)

---

## Quick Start

To create a new custom weather, you need:

1. **Graphics** - PNG files in `Graphics/Weather/`
2. **Registration** - Register both overworld and battle weather
3. **Handlers** - Define battle effects (damage, immunity, type boosts, messages)
4. **Assignment** - Set weather on maps or before battles

---

## Creating a New Weather Type

### Step 1: Create a New Weather File

Create a new file in `Plugins/Custom Weather Plugin/` with a number prefix (e.g., `011_MyWeather.rb`).

### Step 2: Register the Weather

```ruby
CustomWeather.register_weather(
  # Overworld Weather Registration
  {
    :id               => :MyWeather,      # Unique symbol ID
    :id_number        => 13,              # Use 12+ to avoid conflicts
    :category         => :Fog,            # :None, :Rain, :Hail, :Sandstorm, :Sun, :Fog
    :graphics         => [
      ["myweather_1", "myweather_2"],     # Particle graphics (optional)
      ["myweather_tile"]                   # Tile/fog overlay (optional)
    ],
    :particle_delta_x => -40,             # Particle horizontal movement per second
    :particle_delta_y => 15,              # Particle vertical movement per second
    :tile_delta_x     => -48,             # Tile horizontal scroll per second
    :tile_delta_y     => 0,               # Tile vertical scroll per second
    :tone_proc        => proc { |strength|
      # Screen tint (strength is 0-60)
      Tone.new(red, green, blue, gray)
    }
  },
  # Battle Weather Registration
  {
    :id        => :MyWeather,             # Must match overworld ID
    :name      => _INTL("My Weather"),    # Display name
    :animation => "MyWeather"             # Battle animation name
  }
)
```

### Step 3: Register Weather Messages

```ruby
# Message when weather starts
CustomWeather::Handlers::StartMessage.add(:MyWeather,
  proc { |weather, battle|
    next _INTL("My weather began!")
  }
)

# Message each turn weather continues
CustomWeather::Handlers::ContinueMessage.add(:MyWeather,
  proc { |weather, battle|
    next _INTL("My weather continues...")
  }
)

# Message when weather ends
CustomWeather::Handlers::EndMessage.add(:MyWeather,
  proc { |weather, battle|
    next _INTL("My weather ended.")
  }
)
```

### Step 4: Register Battle Effects (Optional)

See [Battle Effects](#battle-effects) section below.

---

## Weather Graphics

### Required Files

Place graphics in `Graphics/Weather/`:

| File | Purpose |
|------|---------|
| `myweather_1.png` | First particle frame |
| `myweather_2.png` | Second particle frame (animates) |
| `myweather_tile.png` | Scrolling fog/overlay texture |

### Particle Graphics

- Small images (e.g., 32x32 or smaller)
- Multiple frames will animate automatically
- Movement controlled by `particle_delta_x` and `particle_delta_y`

### Tile Graphics

- Seamless tiling texture (e.g., 256x256)
- Covers entire screen as scrolling overlay
- Movement controlled by `tile_delta_x` and `tile_delta_y`
- Good for fog, mist, or dense particle effects

### Screen Tone

The `tone_proc` controls screen coloring:

```ruby
:tone_proc => proc { |strength|
  # strength ranges from 0 to 60 based on weather power
  # Tone.new(red, green, blue, gray)
  # Values can be -255 to 255 for RGB, 0 to 255 for gray

  # Examples:
  # Darker: Tone.new(-30, -30, -30, 0)
  # Purple tint: Tone.new(20, -20, 40, 0)
  # Sepia: Tone.new(30, 10, -20, 30)

  next Tone.new(-strength/3, -strength/2, strength/3, 0)
}
```

### Battle Animation

Create a battle animation using the **Essentials Animation Editor** (not RPG Maker XP's Database):

1. Run your game in Debug mode
2. Open Debug Menu > Other Options > **Animation Editor**
3. Create a new animation named exactly: `Common:MyWeather`
4. Add frames, graphics, and sound effects
5. Save - it automatically saves to `PkmnAnimations.rxdata`

**Note:** Weather animations must be in `PkmnAnimations.rxdata`, not `Animations.rxdata`. The standard RPG Maker XP Database > Animations saves to a different file that the battle system doesn't use.

---

## Battle Effects

### End-of-Round Damage

Deal damage to Pokemon at the end of each round:

```ruby
CustomWeather::Handlers::EORDamage.add(:MyWeather,
  proc { |weather, battler, battle|
    next if battler.fainted?
    # Check immunity first
    next if CustomWeather::Handlers.triggerDamageImmunity(:MyWeather, battler)
    # Check if battler takes indirect damage
    next if !battler.takesIndirectDamage?

    # Display message and deal damage
    battle.pbDisplay(_INTL("{1} is hurt by the weather!", battler.pbThis))
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp / 16, false)  # 1/16 HP damage
  }
)
```

### Damage Immunity

Define which Pokemon are immune to weather damage:

```ruby
CustomWeather::Handlers::DamageImmunity.add(:MyWeather,
  proc { |weather, battler|
    # Type immunities
    next true if battler.pbHasType?(:FIRE)
    next true if battler.pbHasType?(:STEEL)

    # Ability immunities
    next true if battler.hasActiveAbility?([:OVERCOAT, :MAGICGUARD])

    # Item immunities
    next true if battler.hasActiveItem?(:SAFETYGOGGLES)

    next false  # Not immune
  }
)
```

### Type Boost

Boost certain move types during this weather:

```ruby
CustomWeather::Handlers::TypeBoost.add(:MyWeather,
  proc { |weather, move_type, user, target|
    next 1.5 if move_type == :FIRE    # 50% boost to Fire moves
    next 0.5 if move_type == :WATER   # 50% reduction to Water moves
    next 1.0  # No change for other types
  }
)
```

### All-in-One Registration

Register all handlers at once:

```ruby
CustomWeather::Handlers.register_all(:MyWeather, {
  :eor_damage => proc { |weather, battler, battle| ... },
  :damage_immunity => proc { |weather, battler| ... },
  :type_boost => proc { |weather, move_type, user, target| ... },
  :start_message => proc { |weather, battle| ... },
  :continue_message => proc { |weather, battle| ... },
  :end_message => proc { |weather, battle| ... }
})
```

---

## Assigning Weather to Maps

### Method 1: Parallel Process Event (Recommended)

1. Create a new event on your map
2. Set trigger to "Parallel Process"
3. Add a Script command with:

```ruby
# Always set weather on this map
CustomWeather.setMapWeather(:PoisonFog)

# Or with probability (75% chance)
CustomWeather.setMapWeather(:PoisonFog, 75)

# Or with custom strength (0-9)
CustomWeather.setMapWeather(:PoisonFog, 100, 7)
```

4. Add a Self Switch to prevent running every frame:

```ruby
# Full example for parallel process
if !pbGet(1)  # Use a variable to track if weather was set
  CustomWeather.setMapWeather(:PoisonFog)
  pbSet(1, true)
end
```

### Method 2: Map Entry Event

Add to a global script or create an event handler:

```ruby
# In a plugin or script section
EventHandlers.add(:on_enter_map, :my_weather_maps,
  proc { |old_map_id|
    # Define which maps have which weather
    map_weather = {
      15 => :PoisonFog,   # Map ID 15 has Poison Fog
      23 => :PoisonFog,   # Map ID 23 has Poison Fog
      42 => :AcidRain     # Map ID 42 has Acid Rain
    }

    weather = map_weather[$game_map.map_id]
    if weather
      $game_screen.weather(weather, 9, 0)
    end
  }
)
```

### Method 3: Direct Script Call

In any event's Script command:

```ruby
# Set weather immediately
pbSetCustomWeather(:PoisonFog)

# Set weather with specific strength (0-9)
pbSetCustomWeather(:PoisonFog, 7)

# Set weather with fade-in duration (frames)
pbSetCustomWeather(:PoisonFog, 9, 40)

# Clear weather
pbClearWeather
```

---

## Assigning Weather to Battles

### Method 1: Before Starting Battle

In an event script, set weather before the battle:

```ruby
# Set battle weather
pbSetBattleWeather(:PoisonFog)

# Then start the battle
WildBattle.start(:WEEZING, 30)
```

Or for trainer battles:

```ruby
pbSetBattleWeather(:PoisonFog)
TrainerBattle.start(:POKEMON_TRAINER, "Toxic")
```

### Method 2: Automatic from Overworld

If the overworld has custom weather active, it automatically converts to battle weather. This is handled by `006_BattleStarting_Extensions.rb`.

### Method 3: Using setBattleRule

```ruby
# Using the standard battle rule system
setBattleRule("weather", :PoisonFog)
WildBattle.start(:GRIMER, 25)
```

### Method 4: Specific Battle with Multiple Rules

```ruby
# Combine multiple battle rules
setBattleRule("weather", :PoisonFog)
setBattleRule("cannotRun")
setBattleRule("double")
WildBattle.start(:GRIMER, 25, :MUKSECONDARY, 25)
```

---

## API Reference

### Script Commands

| Command | Description |
|---------|-------------|
| `pbSetCustomWeather(id, strength, duration)` | Set overworld weather |
| `pbSetBattleWeather(id)` | Set weather for next battle |
| `pbClearWeather(duration)` | Clear all weather |
| `CustomWeather.setMapWeather(id, probability, strength)` | Set map weather with chance |
| `CustomWeather.weatherActive?(id)` | Check if weather is active |
| `CustomWeather.currentWeather` | Get current weather ID |

### Handler Registration

| Handler | Parameters | Returns |
|---------|------------|---------|
| `EORDamage` | `weather, battler, battle` | (none) |
| `DamageImmunity` | `weather, battler` | `true` or `false` |
| `TypeBoost` | `weather, move_type, user, target` | Multiplier (e.g., `1.5`) |
| `StartMessage` | `weather, battle` | Message string |
| `ContinueMessage` | `weather, battle` | Message string |
| `EndMessage` | `weather, battle` | Message string |

### Weather Categories

| Category | Effect |
|----------|--------|
| `:None` | No special behavior |
| `:Rain` | Waters berry plants, last particle is splash |
| `:Hail` | Some abilities check for hail |
| `:Sandstorm` | Some abilities check for sandstorm |
| `:Sun` | Some abilities/evolutions check for sun |
| `:Fog` | Standard fog behavior |

---

## Examples

### Example 1: Acid Rain

```ruby
# 011_AcidRain.rb

CustomWeather.register_weather(
  {
    :id               => :AcidRain,
    :id_number        => 13,
    :category         => :Rain,
    :graphics         => [["rain_1", "rain_2", "rain_3", "rain_4"]],
    :particle_delta_x => -600,
    :particle_delta_y => 2400,
    :tone_proc        => proc { |strength|
      Tone.new(-strength/2, strength/3, -strength/4, 0)
    }
  },
  {
    :id        => :AcidRain,
    :name      => _INTL("Acid Rain"),
    :animation => "AcidRain"
  }
)

# Messages
CustomWeather::Handlers::StartMessage.add(:AcidRain,
  proc { |weather, battle| next _INTL("Acidic rain began to fall!") }
)
CustomWeather::Handlers::ContinueMessage.add(:AcidRain,
  proc { |weather, battle| next _INTL("The acid rain continues to fall.") }
)
CustomWeather::Handlers::EndMessage.add(:AcidRain,
  proc { |weather, battle| next _INTL("The acid rain stopped.") }
)

# Damage: 1/8 HP to non-Poison, non-Steel types
CustomWeather::Handlers::DamageImmunity.add(:AcidRain,
  proc { |weather, battler|
    next true if battler.pbHasType?(:POISON)
    next true if battler.pbHasType?(:STEEL)
    next true if battler.hasActiveAbility?([:OVERCOAT, :RAINDISH])
    next true if battler.hasActiveItem?(:SAFETYGOGGLES)
    next false
  }
)

CustomWeather::Handlers::EORDamage.add(:AcidRain,
  proc { |weather, battler, battle|
    next if battler.fainted?
    next if CustomWeather::Handlers.triggerDamageImmunity(:AcidRain, battler)
    next if !battler.takesIndirectDamage?
    battle.pbDisplay(_INTL("{1} is burned by the acid rain!", battler.pbThis))
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp / 8, false)
  }
)

# Boost Poison moves, weaken Grass moves
CustomWeather::Handlers::TypeBoost.add(:AcidRain,
  proc { |weather, move_type, user, target|
    next 1.3 if move_type == :POISON
    next 0.7 if move_type == :GRASS
    next 1.0
  }
)
```

### Example 2: Ash Fall (No Damage, Visual Only)

```ruby
# 012_AshFall.rb

CustomWeather.register_weather(
  {
    :id               => :AshFall,
    :id_number        => 14,
    :category         => :None,
    :graphics         => [["ash_1", "ash_2"]],
    :particle_delta_x => -60,
    :particle_delta_y => 120,
    :tone_proc        => proc { |strength|
      Tone.new(strength/4, strength/4, strength/4, strength/3)
    }
  },
  {
    :id        => :AshFall,
    :name      => _INTL("Ash Fall"),
    :animation => "AshFall"
  }
)

CustomWeather::Handlers::StartMessage.add(:AshFall,
  proc { |weather, battle| next _INTL("Ash is falling from the sky!") }
)
CustomWeather::Handlers::ContinueMessage.add(:AshFall,
  proc { |weather, battle| next _INTL("Ash continues to fall.") }
)
CustomWeather::Handlers::EndMessage.add(:AshFall,
  proc { |weather, battle| next _INTL("The ash stopped falling.") }
)

# No damage handlers = purely visual weather
# Optionally boost Fire moves slightly
CustomWeather::Handlers::TypeBoost.add(:AshFall,
  proc { |weather, move_type, user, target|
    next 1.2 if move_type == :FIRE
    next 1.0
  }
)
```

---

## Troubleshooting

### Weather not appearing on map
- Check that graphics files exist in `Graphics/Weather/`
- Verify the `:id_number` doesn't conflict with existing weather (use 12+)
- Ensure `pbSetCustomWeather` is being called

### Weather not converting to battle
- Verify both overworld and battle weather use the same `:id`
- Check that `CustomWeather.register_weather` was called with both parameters

### Battle effects not working
- Confirm handlers are registered with correct weather ID
- Check that the weather is actually the "effective weather" (not suppressed by ability)
- Verify handler procs use `next` to return values

### Graphics not animating
- Ensure multiple frames are listed in the graphics array
- Check that files are named correctly and in the right folder

---

## File Structure Reference

```
Plugins/Custom Weather Plugin/
├── meta.txt                          # Plugin metadata
├── docs.md                           # This documentation
├── 001_CustomWeatherModule.rb        # Core module and registries
├── 002_WeatherRegistration.rb        # Registration helpers
├── 003_WeatherEffectHandlers.rb      # Handler methods
├── 004_Battle_Extensions.rb          # Battle class hooks
├── 005_DamageCalc_Extensions.rb      # Damage calculation hooks
├── 006_BattleStarting_Extensions.rb  # Battle start weather conversion
├── 007_ScriptCommands.rb             # Event script API
├── 010_PoisonFog.rb                  # Example: Poison Fog
└── 011_YourWeather.rb                # Your custom weather here
```

---

## Version History

- **1.0.0** - Initial release with Poison Fog example
