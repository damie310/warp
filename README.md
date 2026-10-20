# Warp 

## Commands
- `/warp` — list available warps.
- `/warp <name>` — teleport to a warp.
- `/warplist` — list available warps.
- `/setwarp <name>` — create or update a warp at your current location (**requires `server` privilege**).
- `/delwarp <name>` — delete a warp (**requires `server` privilege**).

## Install
1. Stop your server.
2. Extract the `warp` folder into your server's `mods` directory or the world's `worldmods` directory.
3. Enable it for your world. Add `load_mod_warp = true` to `world.mt`.
4. Start the server.

Warps persist across restarts using mod storage. Names can contain letters, numbers, underscores, and hyphens (up to 32 characters). Any player can use existing warps; only users with the `server` privilege can create, update, or delete them.


