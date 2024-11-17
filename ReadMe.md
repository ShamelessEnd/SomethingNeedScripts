dependencies:
  - SND
  - Autoretainer
  - Lifestream
  - Deliveroo (might replace eventually since it's slow as shit and the flakiest part of the whole process)
  - Pandora's Box (just for `/pcall` which supposedly will eventually get removed in favor of `/callback`, but `/callback` crashes for me so :shrug:)

random notes:
- all these scripts need to be added to SND, with the appropriate name (they reference eachother)
- `ARPostProcess`
  - needs to be registered for autoretainer post process in SND - go to SND help > options > AutoRetainer
  - if you don't want the undercutting script, comment it out
  - other scripts will only run if your inventory is low or you have not enough ventures (see config at top of the file)
  - only operates for characters registered in autoretainer for retainers (`ARGetRegisteredEnabledCharacters()`) - wont run for deployables-only characters
- after GC turn in, characters will tp to fc
  - if that fails, will fallback to hawkers limsa
  - there's a hardcoded override that sends Behemoth characters to the summonning bell next to their apartment instead
    - remove it from `ReturnToBell` if you don't want that or don't have one
- you can run these scripts on their own manually (or in some other automation) outside of ARPostProcess

for the undercutting script:
- can put any plogons that fuck with it in an xlplugins collection called `ARPostUndercutSuppress`, which will get disabled while running
  - I put Market board, Dropbox, Penny Pincher while debugging crashes since they were doing shit, but might not be needed
- script setup is at the top of the file `ARPostUndercut`
  - `undercut_retainers` these retainers will only undercut items you already listed yourself
  - `sell_retainers` is a table with items to list for sale per retainer, along with properties for each item
    - create more entries `[2] = {}, [3] = {}, etc.` for additional retainers.
    - if using this sell logic, delete all your `ITEM_ODR` configs, otherwise it will try to list random shit for sale and probably break (undercutting is fine tho)
      - and never sort your retainer's inventory
      - i probably should figure out how to fix this eventually
    - the script will only sell items from your retainer's inventory (for now)
- what's in the script by default is just my dye selling logic for second retainer, others only undercut
- theres a lot of non-customizable logic baked into the code itself, if you don't like it write your own


