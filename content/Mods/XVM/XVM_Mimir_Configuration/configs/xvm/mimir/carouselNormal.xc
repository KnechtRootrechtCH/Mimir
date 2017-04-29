/**
 * Normal carousel cells settings
 * Настройки ячеек карусели обычного размера
 */
{
  // Definitions
  // Шаблоны
  "def": {
    // Text fields shadow.
    // Тень текстовых полей.
    "textFieldShadow": { "enabled": true, "color": "0x000000", "alpha": 80, "blur": 2, "strength": 2, "distance": 0, "angle": 0 }
  },
  "normal": {
    // Cell width
    // Ширина ячейки
    "width": 160,
    // Cell height
    // Высота ячейки
    "height": 100,
    // Spacing between carousel cells.
    // Отступ между ячейками карусели.
    "gap": 10,
    // Standard cell elements.
    // Стандартные элементы ячеек.
    "fields": {
      // "enabled"  - the visibility of the element / видимость элемента
      // "dx"       - horizontal shift              / смещение по горизонтали
      // "dy"       - vertical shift                / смещение по вертикали
      // "alpha"    - transparency                  / прозрачность
      // "scale"    - scale                         / масштаб
      //
      // Nation flag.
      // Флаг нации.
      "flag": { "enabled": true, "dx": 0, "dy": 0, "alpha": 100, "scale": 1 },
      // Vehicle icon.
      // Иконка танка.
      "tankIcon": { "enabled": true, "dx": 0, "dy": 0, "alpha": 100, "scale": 1 },
      // Vehicle class icon.
      // Иконка типа техники.
      "tankType": { "enabled": true, "dx": 0, "dy": 80, "alpha": 100, "scale": 1 },
      // Vehicle level.
      // Уровень техники
      "level":    { "enabled": false, "dx": 0, "dy": 0, "alpha": 100, "scale": 1 },
      // Double XP icon
      // Иконка не сбитого опыта за первую победу в день.
      "xp":       { "enabled": true, "dx": 0, "dy": 0, "alpha": 100, "scale": 1 },
      // Vehicle name.
      // Название танка.
      "tankName": { "enabled": false, "dx": 0, "dy": 0, "alpha": 100, "scale": 1, "textFormat": {}, "shadow": {} },
      // Vehicle rent info text.
      // Инфо текст аренды танка.
      "rentInfo": { "enabled": true, "dx": 0, "dy": 0, "alpha": 100, "scale": 1, "textFormat": {}, "shadow": {} },
      // Info text (Crew incomplete, Repairs required)
      // Инфо текст (Неполный экипаж, Требуется ремонт).
      "info":     { "enabled": true, "dx": 0, "dy": 0, "alpha": 100, "scale": 1, "textFormat": {}, "shadow": {} },
      // Info image
      // Инфо иконка
      "infoImg":  { "enabled": true, "dx": 0, "dy": 0, "alpha": 100, "scale": 1 },
      // Info text for "Buy vehicle" and "Buy slot" slots.
      // Инфо текст для слотов "Купить машину" и "Купить слот".
      "infoBuy":  { "enabled": true, "dx": 0, "dy": 0, "alpha": 100, "scale": 1, "textFormat": {}, "shadow": {} },
      // Clan lock timer
      // Таймер блокировки танка
      "clanLock": { "enabled": true, "dx": 0, "dy": 0, "alpha": 100 },
      // Price
      // Цена
      "price":    { "enabled": true, "dx": 0, "dy": 0, "alpha": 100 },
      // Action price
      // Акционная цена
      "actionPrice": { "enabled": true, "dx": 0, "dy": 0, "alpha": 100 },
      // Favorite vehicle mark
      // Маркер основной техники
      "favorite": { "enabled": true, "dx": 0, "dy": 0, "alpha": 100 },
      // Stats field that appears on the mouse hover
      // Поле статистики, отображаемое при наведении мыши
      "stats": { "enabled": true, "dx": 0, "dy": 0, "alpha": 100, "textFormat": {}, "shadow": {} }
    },
    // Extra cell fields (extended format supported, see extra-field.txt).
    // Дополнительные поля ячеек (поддерживается расширенный формат, см. extra-field.txt).
    "extraFields": [
      // Tank name
      {
        "enabled": true,
        "x": 156,
        "y": 80,
        "align": "right",
        "format": "<font size='12' face='$FieldFont' color='{{v.premium?#E7B622|#FFFFFF}}'>{{v.name}}</font>",
        "shadow": { "distance": 0, "angle": 0, "color": "{{v.premium?0x642D1A|0x434343}}", "alpha": 100, "blur": 6, "strength": 3 }
      },
      // Tank level and battle tiers
      {
        "enabled": true,
        "x": 20,
        "y": 80,
        "align": "left",
        "format": "<font face='$FieldFont' size='12' color='#7d7d75'><font color='#CFCFCF'><b>{{v.rlevel}}</b></font> {{v.battletiermin}}-{{v.battletiermax}}</font>",
        "shadow": ${ "def.textFieldShadow" }
      },
      // Slot background
      // Подложка слота
      { "x": 1, "y": 1, "layer": "substrate", "width": 160, "height": 100, "bgColor": "0x0A0A0A" },
      // Average damage
      // Средний урон
      {
        "enabled": true,
        "x": 2, "y": 3, "width": 16, "height": 16, "alpha": "{{v.tdb?100|0}}",
        "src": "xvm://res/icons/tooltips/roles/gunner.png"
      },
      {
        "enabled": true,
        "x": 17, "y": 1,
        "format": "<b><font face='$FieldFont' size='12' color='{{v.c_xtdb|#7d7d75}}'>{{v.tdb%d}}</font></b>",
        "shadow": ${ "def.textFieldShadow" }
      },
      // Battle count
      // Количество боёв
      {
        "enabled": true,
        "x": 3, "y": 17, "width": 14, "height": 14, "alpha": "{{v.tdb?70|0}}",
        "src": "xvm://res/icons/carousel/battles.png"
      },
      {
        "enabled": true,
        "x": 17, "y": 14,
        "format": "<b><font face='$FieldFont' size='12' color='#7d7d75'>{{v.battles}}</font></b>",
        "shadow": ${ "def.textFieldShadow" }
      },
      // Damage rating
      // Количество боёв
      {
        "enabled": true,
        "x": 2, "y": 30, "width": 16, "height": 16, "alpha": "{{v.damageRating>50?100|0}}",
        "src": "xvm://res/icons/tooltips/roles/commander.png"
      },
      {
        "enabled": true,
        "x": 17, "y": 27,
        "format": "{{v.damageRating>50?<font face='$FieldFont' size='12' color='#7d7d75'>{{v.damageRating%'d~%}}</font>|}}",
        "shadow": ${ "def.textFieldShadow" }
      },
      // Damage rating
      /*
      {
        "enabled": true,
        "x": 158,
        "y": 66,
        "align": "right",
        "x": 2,
        "y": 66,
        "align": "left",
        "alpha": "{{v.damageRating}}",
        "format": "{{v.damageRating>50?<font face='$FieldFont' size='12' color='#CFCFCF'>{{v.damageRating%'d~%}}</font>|}}",
        "shadow": ${ "def.textFieldShadow" }
      },
      */
      // XP left to elite
      {
        /*
        "enabled": true,
        "x": 2,
        "y": 64,
        "align": "left",
        */
        "x": 156,
        "y": 66,
        "align": "right",
        "format": "<font face='$FieldFont' size='12' color='#7d7d75'>{{v.xpToEliteLeft%'d}}</font>",
        "shadow": ${ "def.textFieldShadow" }
      }
    ]
  }
}
