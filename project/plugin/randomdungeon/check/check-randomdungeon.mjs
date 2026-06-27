#!/usr/bin/env node
/**
 * Random Dungeon Generator — offline design/spec regression checks.
 *
 * Usage: node check-randomdungeon.mjs
 * Exit: 0 = all pass, 1 = one or more failures
 */

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = path.resolve(__dirname, "..");
const REPO_ROOT = path.resolve(PLUGIN_ROOT, "../../..");
const failures = [];
const passes = [];

function pass(name, detail = "") {
  passes.push({ name, detail });
}

function fail(name, detail) {
  failures.push({ name, detail });
}

function exists(absPath, label) {
  if (fs.existsSync(absPath)) {
    pass(label || `exists: ${path.basename(absPath)}`);
    return true;
  }
  fail(label || `missing: ${absPath}`, absPath);
  return false;
}

function readJson(absPath, label) {
  try {
    const data = JSON.parse(fs.readFileSync(absPath, "utf8"));
    pass(label || `valid JSON: ${path.basename(absPath)}`);
    return data;
  } catch (e) {
    fail(label || `invalid JSON: ${absPath}`, String(e.message));
    return null;
  }
}

function mustHaveKeys(obj, keys, label) {
  const missing = keys.filter((k) => !(k in obj));
  if (missing.length) {
    fail(label, `missing keys: ${missing.join(", ")}`);
    return false;
  }
  pass(label);
  return true;
}

// --- docs-exist ---
const docs = [
  path.join(REPO_ROOT, "docs/random-dungeon-design.md"),
  path.join(PLUGIN_ROOT, "README.md"),
  path.join(PLUGIN_ROOT, "docs/reward-model.md"),
  path.join(PLUGIN_ROOT, "docs/generator-mvp.md"),
  path.join(PLUGIN_ROOT, "docs/apply-path.md"),
  path.join(PLUGIN_ROOT, "docs/runtime-events.md"),
  path.join(PLUGIN_ROOT, "docs/verification.md"),
];
for (const d of docs) exists(d, `docs-exist: ${path.basename(d)}`);

// --- plugin.json ---
const pluginJsonPath = path.join(REPO_ROOT, "project/plugin/plugin.json");
const pluginJson = readJson(pluginJsonPath, "plugin.json parse");
if (pluginJson) {
  if (pluginJson.randomdungeon?.enable === true) {
    pass("plugin-json-entry: randomdungeon enabled");
  } else {
    fail("plugin-json-entry", "randomdungeon.enable must be true");
  }
  if (pluginJson.randomdungeon?.lock === false) {
    pass("plugin-json-entry: randomdungeon lock false");
  } else {
    fail("plugin-json-lock", "randomdungeon.lock must be false");
  }
}

// --- plugin.sk ---
const pluginSkPath = path.join(PLUGIN_ROOT, "plugin.sk");
if (exists(pluginSkPath, "plugin.sk exists")) {
  const sk = fs.readFileSync(pluginSkPath, "utf8");
  for (const needle of ["pluginfo", "loadPlugin", '::["SKStudio"]', "editor_postload", "randomdungeon_generate"]) {
    if (sk.includes(needle)) pass(`plugin-sk: includes ${needle}`);
    else fail(`plugin-sk: missing ${needle}`, pluginSkPath);
  }
  if (sk.includes('where = ["editor_map"]')) {
    pass("plugin-sk: editor_map menu scope");
  } else {
    fail("plugin-sk: editor_map scope", pluginSkPath);
  }
}

// --- sample JSON ---
const draft = readJson(
  path.join(PLUGIN_ROOT, "sample/draft-classic.json"),
  "sample/draft-classic.json"
);
if (draft) {
  mustHaveKeys(
    draft,
    ["schemaVersion", "seed", "rooms", "connections", "entities", "runtimeHooks", "quality"],
    "draft-schema: required top-level keys"
  );
  if (draft.rooms?.length >= 2) pass("draft-schema: rooms array");
  else fail("draft-schema: rooms", "need >= 2 rooms");
}

readJson(path.join(PLUGIN_ROOT, "sample/gvar-dungeon.json"), "sample/gvar-dungeon.json");
const gvar = readJson(path.join(PLUGIN_ROOT, "sample/gvar-dungeon.json"));
if (gvar) {
  for (const id of ["G100", "G101", "G102", "G103"]) {
    if (gvar[id]) pass(`gvar-sample: ${id}`);
    else fail(`gvar-sample: ${id}`, "missing in gvar-dungeon.json");
  }
}

readJson(path.join(PLUGIN_ROOT, "sample/macro-result-X050.json"), "macro-result-X050.json");
const macro = readJson(path.join(PLUGIN_ROOT, "sample/macro-result-X050.json"));
if (macro?.X050?.page?.[0]?.cmdblock?.length) {
  pass("macro-sample: X050 cmdblock");
} else if (macro) {
  fail("macro-sample", "X050.page[0].cmdblock required");
}

const eventFiles = ["entrance_talk.json", "chest_score.json", "exit_return.json"];
for (const f of eventFiles) {
  const p = path.join(PLUGIN_ROOT, "sample/events", f);
  const ev = readJson(p, `runtime-template: ${f}`);
  if (ev?.role) pass(`runtime-template: ${f} has role`);
  else if (ev) fail(`runtime-template: ${f}`, "missing role");
}

// --- reward-model consistency ---
const rewardDoc = fs.readFileSync(
  path.join(PLUGIN_ROOT, "docs/reward-model.md"),
  "utf8"
);
const runtimeDoc = fs.readFileSync(
  path.join(PLUGIN_ROOT, "docs/runtime-events.md"),
  "utf8"
);
for (const gvarId of ["G100", "G101", "G102"]) {
  if (rewardDoc.includes(gvarId) && runtimeDoc.includes(gvarId)) {
    pass(`reward-model-consistency: ${gvarId} in both docs`);
  } else {
    fail(`reward-model-consistency: ${gvarId}`, "must appear in reward-model and runtime-events");
  }
}

const chest = readJson(path.join(PLUGIN_ROOT, "sample/events/chest_score.json"));
if (chest?.page?.[0]?.cmdblock?.some((c) => c.lvar === "G101" && c.op === "+=")) {
  pass("reward-model-consistency: chest uses G101 +=");
} else if (chest) {
  fail("reward-model-consistency: chest", "G101 += expected in chest_score.json");
}

// --- manual checklist ---
exists(path.join(PLUGIN_ROOT, "check/MANUAL-CHECKLIST.md"), "MANUAL-CHECKLIST.md");

// --- report ---
console.log(`\nRandom Dungeon check: ${passes.length} pass, ${failures.length} fail\n`);
for (const p of passes) {
  console.log(`  PASS  ${p.name}${p.detail ? ` — ${p.detail}` : ""}`);
}
for (const f of failures) {
  console.log(`  FAIL  ${f.name}${f.detail ? ` — ${f.detail}` : ""}`);
}

process.exit(failures.length ? 1 : 0);
