# WoW-Forever Recipe Tracker (RFT)

Guild addon for **World of Warcraft: Forever** (patch **1.60.1**, client build **~70790**). Browse learnable profession recipes, see where they come from, and get alerts when a vendor or mob can teach you something new.

Built for the **WoW-Forever** guild. Plain Lua/XML, no Ace3.

## Install

1. Copy the `WoWForeverRFT` folder into your Forever AddOns directory:

   ```
   World of Warcraft/_forever_/Interface/AddOns/WoWForeverRFT
   ```

2. Restart the client (TOC or new XML files require a full restart; `/reload` is enough for Lua-only edits).

3. Confirm the addon is not “Out of date”: the Forever TOC declares `## Interface: 16001`.

## Slash commands

| Command | Action |
|--------|--------|
| `/rft` | Toggle the recipe browser |
| `/rft refresh` | Rescan recipes your character knows |
| `/rft sources` | Print catalog build metadata |
| `/rft minimap` | Show the minimap button if hidden |
| `/rft snooze clear` | Clear all 30-minute alert snoozes |

Open the browser from the **minimap button** (left-click). Right-click the button to hide it.

## Features

1. **Recipe browser** — Pick a profession; list all catalog recipes with ✓ known vs ○ unknown; sorted with unknown first.
2. **Recipe sources** — Click a recipe for trainers, vendors, and mob drops. Missing data is called out in orange.
3. **Vendor alert** — On merchant open (or near an NPC merchant), popup for sellable recipes you do not know yet. **Snooze 30m** per vendor+recipe (SavedVariables).
4. **Mob alert** — On target/mouseover/nameplate, popup when the NPC drops an unknown learnable recipe (same snooze rules).
5. **Mob tooltip** — Extra tooltip section listing recipe drops; highlights unknown recipes.

## Data sources

| Data | Source |
|------|--------|
| Recipe names, profession groupings, crafted items | Blizzard **Battle.net Game Data API** namespace `static-forever-{region}` (`/data/wow/profession/*`, `/data/wow/recipe/{id}`) via `scripts/generate_recipe_data.py` |
| Whether you know a recipe | In-game **`C_TradeSkillUI.IsRecipeKnown`** + **`C_Professions`** |
| Vendor locations/prices | **Merchant scan** at runtime (`C_MerchantFrame` / `GetMerchantItemLink`) stored in SavedVariables |
| Mob drops | Shipped **sparse** `mobDrops` table + **loot chat** + player discoveries in SavedVariables |

This repo **does not** scrape or ship Wowhead (or similar) wholesale databases.

### Regenerating recipe data

```bash
export BLIZZARD_CLIENT_ID=your_app_client_id
export BLIZZARD_CLIENT_SECRET=your_app_client_secret
export BLIZZARD_REGION=us   # optional: us, eu, kr, tw

python3 scripts/generate_recipe_data.py
```

The script overwrites `WoWForeverRFT/Data/RecipeCatalog.lua`. Credentials are **only** read from the environment and are never committed.

**Shipped seed catalog:** ~24 example recipes so the addon runs before you regenerate. Run the script for the full set (~2,494 recipes per wowdb.dev checks).

### Battle.net limitations (verified externally)

Community probes of `static-forever-us` report:

- Recipe documents include **crafted item** and **reagents**, not **trainer**, **vendor**, or **drop** locations.
- `/data/wow/creature/{id}` and `/data/wow/spell/{id}` return **404** on Forever static data.
- Versioned namespaces like `static-1.60.1_70790-forever` may **403**; use `static-forever-{region}`.

## Lint / test

```bash
make lint
```

Requires [luacheck](https://luacheck.readthedocs.io/) (`luarocks install luacheck`). There is no in-client unit test harness; validate in-game on Forever.

## API and TOC assumptions

### Verified (secondary sources, not live client in this build environment)

| Topic | Value / behavior | Sources |
|-------|------------------|---------|
| Forever TOC interface | **`16001`** | [Warcraft Wiki TOC format](https://warcraft.wiki.gg/wiki/TOC_format), [foreverbase install guide](https://foreverbase.org/en/addons/install/) |
| Game type / project id | `forever` (alias `camelot`), **`WOW_PROJECT_CAMELOT` = 18** | Wiki, [Tautellini Forever addon notes](https://github.com/Tautellini/TautelliniAddons/blob/main/docs/forever-addon-development.md) |
| Client API family | **Mainline / retail-style** (not Classic Era) | Blizzard Classic+ blog (cited in Tautellini doc), community API articles |
| Battle.net static namespace | `static-forever-{region}` → professions/recipes | [mhuijskens Forever API notes](https://mhuijskens.com/WoWForever/Api/), [wowdb.dev/forever-api](https://wowdb.dev/forever-api) |
| Install path | `_forever_/Interface/AddOns` | foreverbase, Tautellini doc |

### Assumed in code (change in one place if your client differs)

| Topic | Assumption |
|-------|------------|
| Known recipes | `C_TradeSkillUI.IsRecipeKnown(recipeID)` and `C_Professions.GetProfessionInfo` |
| All recipes for a profession (offline) | Primary list from **generated catalog**; optional `C_TradeSkillUI.GetRecipeIDsForProfession` when present |
| Merchants | `C_MerchantFrame.GetItemLink` with **Classic-style fallbacks** (`GetMerchantItemLink`) |
| Tooltips | `TooltipDataProcessor` + **fallback** `GameTooltip:HookScript("OnTooltipSetUnit")` |
| Recipe skill gates | Catalog `skill` field (0 in API-generated data until enriched); alerts use profession skill from `C_Professions` when available |

**Not verified here:** exact spelling of `C_TradeSkillUI.GetRecipeIDsForProfession` on build 70790. If it is missing, the browser still works from catalog data; only live API-based profession scans are skipped.

## Known limitations

- Full **drop tables** and **trainer lists** are not available from Blizzard’s Forever static API; UI shows gaps explicitly.
- Seed **mob drop** entries are examples (e.g. Hogger → one recipe) — expand via gameplay or guild data collection.
- **Secret values** and combat restrictions from Mainline apply; this addon avoids combat-sensitive logic.
- Alerts can repeat for different recipes from the same vendor/mob; each recipe has its own snooze key.

## License

Non-commercial guild utility. No telemetry — only `WoWForeverRFTDB` SavedVariables on your machine.