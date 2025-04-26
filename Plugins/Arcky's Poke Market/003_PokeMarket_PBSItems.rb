module GameData
  class Item
    attr_reader :sell_bp_price, :coin_price, :sell_coin_price

    alias_method :initialize_original, :initialize

    SCHEMA["SellBPPrice"] = [:sell_bp_price, "u"]
    SCHEMA["CoinPrice"] = [:coin_price, "u"]
    SCHEMA["SellCoinPrice"] = [:sell_coin_price, "u"]


    def self.editor_properties
      field_use_array = [_INTL("Can't use in field")]
      self.schema["FieldUse"][2].each { |key, value| field_use_array[value] = key if !field_use_array[value] }
      battle_use_array = [_INTL("Can't use in battle")]
      self.schema["BattleUse"][2].each { |key, value| battle_use_array[value] = key if !battle_use_array[value] }
      return [
        ["ID",                ReadOnlyProperty,                                 _INTL("ID of this item (used as a symbol like :XXX).")],
        ["Name",              ItemNameProperty,                                 _INTL("Name of this item as displayed by the game.")],
        ["NamePlural",        ItemNameProperty,                                 _INTL("Plural name of this item as displayed by the game.")],
        ["PortionName",       ItemNameProperty,                                 _INTL("Name of a portion of this item as displayed by the game.")],
        ["PortionNamePlural", ItemNameProperty,                                 _INTL("Name of 2 or more portions of this item as displayed by the game.")],
        ["Pocket",            PocketProperty,                                   _INTL("Pocket in the Bag where this item is stored.")],
        ["Price",             LimitProperty.new(Settings::MAX_MONEY),           _INTL("Purchase price of this item.")],
        ["SellPrice",         LimitProperty2.new(Settings::MAX_MONEY),          _INTL("Sell price of this item. If blank, is half the purchase price.")],
        ["BPPrice",           LimitProperty.new(Settings::MAX_BATTLE_POINTS),   _INTL("Purchase price of this item in Battle Points (BP).")],
        ["SellBPPrice",       LimitProperty2.new(Settings::MAX_BATTLE_POINTS),  _INTL("Sell price of this item in Battle Points (BP). If blank, is half the purchase price.")],
        ["CoinPrice",         LimitProperty.new(Settings::MAX_COINS),           _INTL("Purchase price of this item in Coins")],
        ["SellCoinPrice",     LimitProperty2.new(Settings::MAX_COINS),          _INTL("Sell price of this item in Coins. If blank, is half the purchase price.")],
        ["FieldUse",          EnumProperty.new(field_use_array),                _INTL("How this item can be used outside of battle.")],
        ["BattleUse",         EnumProperty.new(battle_use_array),               _INTL("How this item can be used within a battle.")],
        ["Flags",             StringListProperty,                               _INTL("Words/phrases that can be used to group certain kinds of items.")],
        ["Consumable",        BooleanProperty,                                  _INTL("Whether this item is consumed after use.")],
        ["ShowQuantity",      BooleanProperty,                                  _INTL("Whether the Bag shows how many of this item are in there.")],
        ["Move",              MoveProperty,                                     _INTL("Move taught by this HM, TM or TR.")],
        ["Description",       StringProperty,                                   _INTL("Description of this item.")]
      ]
    end

    def initialize(hash)
      initialize_original(hash)
      @sell_bp_price = hash[:sell_bp_price] || @bp_price / 2
      @coin_price = hash[:coin_price] || 1
      @sell_coin_price = hash[:sell_coin_price] || @coin_price / 2
    end
  end
end
