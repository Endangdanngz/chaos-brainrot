// A working roblox-brainrot-01 entry (Node 22, standard library only): the game is this directory's Rojo
// project, built into game.rbxl with `rojo build default.project.json --output game.rbxl`, and the program
// hands it in. It copies game.rbxl, src/, screenshots/ and PLAY.json from beside this file to /output and
// writes /output/dossier.json, the summary the judge reads, with the vendored make.fun library. A preflight
// section checks PLAY.json and the screenshots against the scorer's own rules before anything is copied, and
// stops with a clear error if either would be refused. A starting
// point, not a winner: it is a grey square that moves with the arrow keys. Build your game, rebuild
// game.rbxl, put your PNG or JPEG screenshots in screenshots/ (the first by name is the cover, and one of
// them is the thumbnail you upload for your game on Roblox) and fill in PLAY.json with your published place.
//
// Every name under /output starts with a letter, a digit or _ and holds only letters, digits, . _ and -: the
// grader fails an entry whose output holds any other, so a file such as .gitkeep or .DS_Store copied in fails it.
// So src/ and screenshots/ are copied without any name that starts with a dot, at any depth.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// Preflight, before anything is copied: fail here, with a clear error, on an entry the scorer would refuse
// anyway. PLAY.json must name the real published place: place_id and universe_id are positive whole numbers,
// and url is that place's own page, https://www.roblox.com/games/<place_id>, with nothing after the id but an
// optional trailing slug. The screenshots directory must hold 3 or 4 image files (.jpg, .jpeg or .png) and
// every one of them must be at most 256 KiB.

const play = JSON.parse(readFileSync(join(here, 'PLAY.json'), 'utf8')) as { place_id?: unknown; universe_id?: unknown; url?: unknown };
const isPositiveWhole = (value: unknown): value is number => typeof value === 'number' && Number.isInteger(value) && value > 0;
const placeId = play.place_id;
const universeId = play.universe_id;
if (!isPositiveWhole(placeId)) throw new Error(`PLAY.json: place_id must be a positive whole number, got ${JSON.stringify(placeId)}`);
if (!isPositiveWhole(universeId)) throw new Error(`PLAY.json: universe_id must be a positive whole number, got ${JSON.stringify(universeId)}`);
const placeUrl = `https://www.roblox.com/games/${placeId}`;
if (play.url !== placeUrl && !(typeof play.url === 'string' && play.url.startsWith(`${placeUrl}/`))) {
  throw new Error(`PLAY.json: url must be ${placeUrl} (a trailing slug after the id is fine), got ${JSON.stringify(play.url)}`);
}

const screenshotDir = join(here, 'screenshots');
const imageNames = existsSync(screenshotDir) ? readdirSync(screenshotDir).filter((name) => /\.(?:jpe?g|png)$/i.test(name)) : [];
if (imageNames.length < 3 || imageNames.length > 4) {
  throw new Error(`screenshots/: expected 3 or 4 image files (.jpg, .jpeg or .png), found ${imageNames.length}`);
}
for (const name of imageNames) {
  const size = statSync(join(screenshotDir, name)).size;
  if (size > 262144) throw new Error(`screenshots/${name}: ${size} bytes is over the 256 KiB cap of 262144 bytes`);
}

/** cpSync's filter: leave out every file and directory whose name starts with a dot (.gitkeep, .DS_Store, .git). */
const notDotted = (path: string): boolean => !basename(path).startsWith('.');

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: notDotted });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(join(here, 'screenshots'))) cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: notDotted });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others refuse an entry the
// scorer would refuse (more than 4 screenshots or one over 256 KiB; a place of more than 500000 instances, whose
// scripts' sources come to over 8 MiB or whose scripts' paths come to over 1048576 characters, in all).
writeFileSync(
  join(out, 'dossier.json'),
  buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);
