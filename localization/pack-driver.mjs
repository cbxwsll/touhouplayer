import { mkdir, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { createThcrapClient, downloadThcrapPack } from "/home/cbx/thcrap-pack/integrations/thcrap-local.mjs";
import { ThcrapRuntimeCompiler } from "/home/cbx/thcrap-pack/server/thcrap-compiler.mjs";
import { ThtkRunner } from "/home/cbx/thcrap-pack/server/thtk-runner.mjs";

const game = process.argv[2] || "th08";
const lang = process.argv[3] || "lang_zh-hans";
const ARCHIVES = {
  th06: ["/home/cbx/games/th06/紅魔郷IN.DAT", "/home/cbx/games/th06/紅魔郷ED.DAT", "/home/cbx/games/th06/紅魔郷CM.DAT", "/home/cbx/games/th06/紅魔郷MD.DAT", "/home/cbx/games/th06/紅魔郷ST.DAT", "/home/cbx/games/th06/紅魔郷TL.DAT"],
  th07: ["/home/cbx/games/th07/th07.dat"],
  th08: ["/home/cbx/games/th08/th08.dat"],
  th09: ["/home/cbx/games/th09/th09.dat"],
  th10: ["/home/cbx/games/th10/th10.dat"],
  th11: ["/home/cbx/games/th11/th11.dat"],
  th15: ["/home/cbx/games/th15/th15.dat"]
};
const outRoot = `/home/cbx/games/lang/${game}`;

const client = createThcrapClient({});
console.log(`resolving ${lang} for ${game} ...`);
const pack = await client.resolveLanguage(lang, game);
console.log("assets:", pack.assets.length, "deps:", pack.dependencies.join(", "));
const downloaded = await downloadThcrapPack(pack, {
  concurrency: 6,
  onProgress: p => { if (p.completed % 25 === 0 || p.completed === p.total) console.log(`dl ${p.completed}/${p.total}`); }
});
const runner = new ThtkRunner({ thdat: "/home/cbx/thtk/build/thdat/thdat", thmsg: "/home/cbx/thtk/build/thmsg/thmsg" });
const compiler = new ThcrapRuntimeCompiler({ runner, archives: { [game]: ARCHIVES[game] } });
const processed = await compiler.processPack(downloaded.resources);
let written = 0;
for (const r of processed) {
  const target = r.targetPath || r.mountPath;
  if (!target) { console.log("skip", r.path); continue; }
  const prefix = `/thcrap/${game}/`;
  const rel = target.startsWith(prefix) ? target.slice(prefix.length) : target.replace(/^\//, "");
  const dest = join(outRoot, rel);
  await mkdir(dirname(dest), { recursive: true });
  await writeFile(dest, Buffer.from(r.bytes));
  written++;
  console.log("out", rel, r.format, r.bytes.length);
}
console.log("DONE", game, lang, "written", written);
