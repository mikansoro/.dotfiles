/**
 * llama-swap provider for pi
 *
 * Connects pi to a self-hosted llama-swap server and integrates it into pi's
 * auth, model selection, and configuration flows.
 *
 * --- Usage -----------------------------------------------------------------
 *
 *   /login                      Pick "Use a subscription" -> "llama-swap".
 *                               Prompts for server URL and API key, then
 *                               discovers models from /v1/models.
 *
 *   /model                      Pick any llama-swap/<id> model.
 *
 *   /llama-swap                 Settings menu: edit URL, edit API key, test
 *                               connection, reload models, configure a model,
 *                               or clear credentials.
 *
 *   /llama-swap-reload          Re-fetch the model list.
 *   /llama-swap-configure [id]  Jump straight into per-model config.
 *
 * --- Declarative override (for nix / home-manager) -------------------------
 *
 * Environment variables override stored credentials and skip the /login flow:
 *
 *   LLAMA_SWAP_URL=http://ollama.int.example.com:11395 \
 *   LLAMA_SWAP_API_KEY=optional-key \
 *     pi
 *
 * --- Files -----------------------------------------------------------------
 *
 *   ~/.pi/agent/llama-swap.json  Connection config, discovered model ids,
 *                                and per-model overrides.
 */

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import type { OAuthCredentials, OAuthLoginCallbacks } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const PROVIDER = "llama-swap";
const DEFAULT_URL = "http://localhost:8080";
const URL_ENV = "LLAMA_SWAP_URL";
const API_KEY_ENV = "LLAMA_SWAP_API_KEY";
const SIDECAR_PATH = join(homedir(), ".pi", "agent", "llama-swap.json");
const NO_AUTH_LITERAL = "llama-swap-no-auth";

// llama.cpp context-overflow phrases that pi's built-in patterns don't cover.
const LLAMA_CPP_OVERFLOW_PATTERNS: readonly RegExp[] = [
	/n_ctx/i,
	/context (size|window|length).{0,30}(exceed|too small|too short|full|overflow)/i,
	/exceed(s|ed).{0,30}context (size|window|length|limit)/i,
	/prompt is too long/i,
	/input (is )?too (long|large)/i,
	/token(s)? (exceed|over the limit)/i,
];

// =============================================================================
// Types
// =============================================================================

type ThinkingFormat =
	| ""
	| "openai"
	| "openrouter"
	| "deepseek"
	| "together"
	| "zai"
	| "qwen"
	| "qwen-chat-template";

interface ModelOverride {
	name?: string;
	reasoning?: boolean;
	input?: ("text" | "image")[];
	contextWindow?: number;
	maxTokens?: number;
	thinkingFormat?: ThinkingFormat;
}

interface Sidecar {
	baseUrl?: string;
	apiKey?: string;
	discoveredModels?: string[];
	overrides?: Record<string, ModelOverride>;
}

// =============================================================================
// Sidecar (connection config + model cache + per-model overrides)
// =============================================================================

function readSidecar(): Sidecar {
	try {
		return JSON.parse(readFileSync(SIDECAR_PATH, "utf-8"));
	} catch {
		return {};
	}
}

function writeSidecar(sc: Sidecar): void {
	mkdirSync(dirname(SIDECAR_PATH), { recursive: true });
	writeFileSync(SIDECAR_PATH, `${JSON.stringify(sc, null, 2)}\n`);
}

function maskKey(key: string): string {
	if (!key) return "(none)";
	if (key.length <= 4) return "●".repeat(key.length);
	return `${"●".repeat(Math.min(6, key.length - 4))}${key.slice(-4)}`;
}

function hostport(url: string): string {
	try {
		const u = new URL(url);
		return u.port ? `${u.hostname}:${u.port}` : u.hostname;
	} catch {
		return url;
	}
}

// =============================================================================
// URL / key resolution (env > sidecar > default)
// =============================================================================

interface Resolved {
	url: string;
	apiKey: string;
	source: "env" | "stored" | "default";
}

function normalizeUrl(raw: string): string {
	const trimmed = raw.trim().replace(/\/+$/, "");
	return /\/v\d+$/.test(trimmed) ? trimmed : `${trimmed}/v1`;
}

function resolveConfig(sc: Sidecar): Resolved {
	const envUrl = process.env[URL_ENV];
	const envKey = process.env[API_KEY_ENV];
	if (envUrl) {
		return { url: normalizeUrl(envUrl), apiKey: envKey ?? "", source: "env" };
	}
	if (sc.baseUrl) {
		return {
			url: normalizeUrl(sc.baseUrl),
			apiKey: sc.apiKey ?? envKey ?? "",
			source: "stored",
		};
	}
	return { url: normalizeUrl(DEFAULT_URL), apiKey: envKey ?? "", source: "default" };
}

// =============================================================================
// Model discovery
// =============================================================================

async function fetchModelIds(baseUrl: string, apiKey: string): Promise<string[]> {
	const headers: Record<string, string> = { Accept: "application/json" };
	if (apiKey) headers.Authorization = `Bearer ${apiKey}`;

	const resp = await fetch(`${baseUrl}/models`, { headers });
	if (!resp.ok) {
		const body = await resp.text().catch(() => "");
		throw new Error(
			`GET ${baseUrl}/models -> ${resp.status} ${resp.statusText}${body ? `: ${body.slice(0, 200)}` : ""}`,
		);
	}
	const payload = (await resp.json()) as { data?: Array<{ id?: string }> };
	return Array.from(
		new Set(
			(payload.data ?? [])
				.map((m) => m.id)
				.filter((id): id is string => typeof id === "string" && id.length > 0),
		),
	);
}

function reasoningHeuristic(id: string): boolean {
	const l = id.toLowerCase();
	if (/\b(qwq|qvq|gpt-?oss|magistral|nemotron)\b/.test(l)) return true;
	if (/(^|[-_/])(r1|o[134])([-_]|$)/.test(l)) return true;
	if (l.includes("reasoning") || l.includes("thinking")) return true;
	return false;
}

function buildModels(ids: string[], sc: Sidecar) {
	const overrides = sc.overrides ?? {};
	return ids.map((id) => {
		const o = overrides[id] ?? {};
		const compat: Record<string, any> = {
			supportsStore: false,
			supportsDeveloperRole: false,
			supportsReasoningEffort: false,
			supportsUsageInStreaming: true,
			supportsStrictMode: false,
			maxTokensField: "max_tokens",
		};
		if (o.thinkingFormat && o.thinkingFormat.length > 0) {
			compat.thinkingFormat = o.thinkingFormat;
		}
		return {
			id,
			name: o.name ?? id,
			reasoning: o.reasoning ?? reasoningHeuristic(id),
			input: o.input ?? (["text"] as ("text" | "image")[]),
			cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
			contextWindow: o.contextWindow ?? 131072,
			maxTokens: o.maxTokens ?? 8192,
			compat,
		};
	});
}

// =============================================================================
// Provider registration
// =============================================================================

function register(pi: ExtensionAPI, url: string, apiKey: string, sc: Sidecar): void {
	pi.registerProvider(PROVIDER, {
		name: "llama-swap",
		baseUrl: url,
		apiKey: apiKey || NO_AUTH_LITERAL,
		api: "openai-completions",
		models: buildModels(sc.discoveredModels ?? [], sc),
		oauth: {
			name: "llama-swap (local LLM gateway)",
			async login(callbacks: OAuthLoginCallbacks): Promise<OAuthCredentials> {
				const current = resolveConfig(readSidecar());

				const urlInput = await callbacks.onPrompt({
					message: `llama-swap base URL (default: ${current.url}):`,
				});
				const chosenUrlRaw = (urlInput ?? "").trim() || current.url;
				const chosenUrl = normalizeUrl(chosenUrlRaw);

				const keyInput = await callbacks.onPrompt({
					message: current.apiKey
						? "API key (press Enter to keep current, or type 'none' to clear):"
						: "API key (press Enter for none):",
				});
				let chosenKey: string;
				if (keyInput === undefined || keyInput.trim() === "") {
					chosenKey = current.apiKey;
				} else if (keyInput.trim().toLowerCase() === "none") {
					chosenKey = "";
				} else {
					chosenKey = keyInput.trim();
				}

				const ids = await fetchModelIds(chosenUrl, chosenKey);

				const fresh = readSidecar();
				fresh.baseUrl = chosenUrlRaw;
				fresh.apiKey = chosenKey;
				fresh.discoveredModels = ids;
				writeSidecar(fresh);

				register(pi, chosenUrl, chosenKey, fresh);

				return {
					refresh: chosenUrlRaw,
					access: chosenKey,
					expires: Number.MAX_SAFE_INTEGER,
				};
			},

			async refreshToken(creds: OAuthCredentials): Promise<OAuthCredentials> {
				return creds;
			},

			getApiKey(creds: OAuthCredentials): string {
				return creds.access || NO_AUTH_LITERAL;
			},
		},
	});
}

// =============================================================================
// Interactive: /llama-swap-configure
// =============================================================================

const FIELD_KEYS = ["name", "context", "output", "reasoning", "vision", "thinking", "reset", "done"] as const;
type FieldKey = (typeof FIELD_KEYS)[number];

function describe(modelId: string, sc: Sidecar): { lines: string[]; field: Record<string, FieldKey> } {
	const o = sc.overrides?.[modelId] ?? {};
	const effective = {
		name: o.name ?? modelId,
		context: o.contextWindow ?? 131072,
		output: o.maxTokens ?? 8192,
		reasoning: o.reasoning ?? reasoningHeuristic(modelId),
		vision: (o.input ?? ["text"]).includes("image"),
		thinking: o.thinkingFormat ?? "(default)",
	};
	const items = [
		[`Name: ${effective.name}`, "name"],
		[`Context window: ${effective.context.toLocaleString()} tokens`, "context"],
		[`Max output tokens: ${effective.output.toLocaleString()}`, "output"],
		[`Reasoning model: ${effective.reasoning ? "yes" : "no"}`, "reasoning"],
		[`Vision input: ${effective.vision ? "yes" : "no"}`, "vision"],
		[`Thinking format: ${effective.thinking}`, "thinking"],
		["── Reset all overrides for this model", "reset"],
		["✓ Done", "done"],
	] as const;
	return {
		lines: items.map(([l]) => l),
		field: Object.fromEntries(items.map(([l, k]) => [l, k as FieldKey])),
	};
}

async function configureModel(pi: ExtensionAPI, ctx: any, modelId: string): Promise<void> {
	let sc = readSidecar();
	while (true) {
		const { lines, field } = describe(modelId, sc);
		const picked = await ctx.ui.select(`Configure ${modelId}`, lines);
		if (!picked) return;
		const key = field[picked];
		if (key === "done") break;

		const current = sc.overrides?.[modelId] ?? {};
		const next: ModelOverride = { ...current };

		if (key === "name") {
			const v = await ctx.ui.input(
				`Display name for ${modelId}`,
				current.name ?? modelId,
			);
			if (v === undefined) continue;
			next.name = v.trim() || undefined;
		} else if (key === "context") {
			const v = await ctx.ui.input(
				"Context window in tokens",
				String(current.contextWindow ?? 131072),
			);
			if (v === undefined) continue;
			const n = parseInt(v.trim(), 10);
			if (Number.isFinite(n) && n > 0) next.contextWindow = n;
		} else if (key === "output") {
			const v = await ctx.ui.input(
				"Max output tokens",
				String(current.maxTokens ?? 8192),
			);
			if (v === undefined) continue;
			const n = parseInt(v.trim(), 10);
			if (Number.isFinite(n) && n > 0) next.maxTokens = n;
		} else if (key === "reasoning") {
			const v = await ctx.ui.confirm(
				"Reasoning model?",
				`Enable thinking/reasoning for ${modelId}?`,
			);
			next.reasoning = v;
		} else if (key === "vision") {
			const v = await ctx.ui.confirm(
				"Vision input?",
				`Does ${modelId} accept images?`,
			);
			next.input = v ? ["text", "image"] : ["text"];
		} else if (key === "thinking") {
			const choices = [
				"(default — let pi pick based on model)",
				"qwen-chat-template (Qwen3 via llama.cpp)",
				"qwen (DashScope-style enable_thinking)",
				"openai (reasoning_effort)",
				"openrouter",
				"deepseek",
				"together",
				"zai",
			];
			const v = await ctx.ui.select("Thinking format", choices);
			if (!v) continue;
			next.thinkingFormat = v.startsWith("(default")
				? ""
				: (v.split(" ")[0] as ThinkingFormat);
		} else if (key === "reset") {
			if (sc.overrides) {
				delete sc.overrides[modelId];
				if (Object.keys(sc.overrides).length === 0) sc.overrides = undefined;
			}
			writeSidecar(sc);
			ctx.ui.notify(`Cleared overrides for ${modelId}`, "info");
			continue;
		}

		sc.overrides = sc.overrides ?? {};
		sc.overrides[modelId] = next;
		writeSidecar(sc);
	}

	const cfg = resolveConfig(sc);
	register(pi, cfg.url, cfg.apiKey, sc);
	ctx.ui.notify(`Saved overrides for ${modelId}`, "info");
}

// =============================================================================
// Entry point
// =============================================================================

export default async function (pi: ExtensionAPI) {
	let sc = readSidecar();
	const cfg = resolveConfig(sc);

	// Live-discover models on startup when a URL source exists.
	if (cfg.source !== "default") {
		try {
			const ids = await fetchModelIds(cfg.url, cfg.apiKey);
			sc.discoveredModels = ids;
			writeSidecar(sc);
		} catch (err) {
			console.error(
				`[llama-swap] discovery from ${cfg.url}/models failed: ${err instanceof Error ? err.message : String(err)}`,
			);
			console.error(
				`[llama-swap] using ${sc.discoveredModels?.length ?? 0} cached model(s). Run /llama-swap-reload after the server is reachable.`,
			);
		}
	}

	// Register with zero models when no URL is configured so /login works but
	// stale cached ids don't appear pointing at an unknown URL.
	const registerSc: Sidecar = cfg.source === "default" ? { ...sc, discoveredModels: [] } : sc;
	register(pi, cfg.url, cfg.apiKey, registerSc);

	// -- /llama-swap-reload -------------------------------------------------
	pi.registerCommand("llama-swap-reload", {
		description: "Re-discover models from your llama-swap server",
		handler: async (_args, ctx) => {
			try {
				const cur = resolveConfig(readSidecar());
				const ids = await fetchModelIds(cur.url, cur.apiKey);
				const updated = readSidecar();
				updated.discoveredModels = ids;
				writeSidecar(updated);
				register(pi, cur.url, cur.apiKey, updated);
				ctx.ui.notify(
					`llama-swap: ${ids.length} model${ids.length === 1 ? "" : "s"} from ${cur.url}`,
					"info",
				);
			} catch (err) {
				ctx.ui.notify(
					`llama-swap reload failed: ${err instanceof Error ? err.message : String(err)}`,
					"error",
				);
			}
		},
	});

	// -- /llama-swap-configure [model] --------------------------------------
	pi.registerCommand("llama-swap-configure", {
		description: "Edit per-model settings for a llama-swap model",
		getArgumentCompletions: (prefix: string) => {
			const ids = readSidecar().discoveredModels ?? [];
			return ids
				.filter((id) => id.startsWith(prefix))
				.map((id) => ({ value: id, label: id }));
		},
		handler: async (args, ctx) => {
			const ids = readSidecar().discoveredModels ?? [];
			if (ids.length === 0) {
				ctx.ui.notify(
					"No llama-swap models discovered yet. Run /login or /llama-swap-reload first.",
					"warning",
				);
				return;
			}
			let modelId = args.trim();
			if (!modelId || !ids.includes(modelId)) {
				const picked = await ctx.ui.select("Configure which model?", ids);
				if (!picked) return;
				modelId = picked;
			}
			await configureModel(pi, ctx, modelId);
		},
	});

	// -- /llama-swap (unified settings menu) --------------------------------
	pi.registerCommand("llama-swap", {
		description: "llama-swap settings (URL, key, models, credentials)",
		handler: async (_args, ctx) => {
			while (true) {
				const scNow = readSidecar();
				const current = resolveConfig(scNow);
				const modelCount = scNow.discoveredModels?.length ?? 0;
				const overrideCount = Object.keys(scNow.overrides ?? {}).length;
				const src =
					current.source === "env"
						? " (from $LLAMA_SWAP_URL)"
						: current.source === "stored"
							? ""
							: " (default — not configured)";

				const envLocked = current.source === "env";
				const urlLine = `Server URL: ${current.url}${src}`;
				const keyLine = `API key: ${maskKey(current.apiKey)}${process.env[API_KEY_ENV] ? " (from $LLAMA_SWAP_API_KEY)" : ""}`;
				const testLine = "Test connection";
				const reloadLine = `Reload models (${modelCount} known)`;
				const configureLine = `Configure model... (${overrideCount} overridden)`;
				const logoutLine = "── Clear stored credentials";
				const closeLine = "✓ Close";

				const items = [urlLine, keyLine, testLine, reloadLine, configureLine, logoutLine, closeLine];
				const picked = await ctx.ui.select("llama-swap settings", items);
				if (!picked || picked === closeLine) return;

				if (picked === urlLine) {
					if (envLocked) {
						ctx.ui.notify(
							"Server URL is set via $LLAMA_SWAP_URL. Unset the env var to edit it here.",
							"warning",
						);
						continue;
					}
					const v = await ctx.ui.input("llama-swap base URL", current.url);
					if (v === undefined || !v.trim()) continue;
					const newUrl = normalizeUrl(v);
					try {
						const ids = await fetchModelIds(newUrl, current.apiKey);
						const updated = readSidecar();
						updated.baseUrl = v.trim();
						updated.discoveredModels = ids;
						writeSidecar(updated);
						register(pi, newUrl, current.apiKey, updated);
						ctx.ui.notify(`llama-swap: ${ids.length} model(s) at ${newUrl}`, "info");
					} catch (err) {
						ctx.ui.notify(
							`Could not reach ${newUrl}: ${err instanceof Error ? err.message : String(err)}`,
							"error",
						);
					}
				} else if (picked === keyLine) {
					if (process.env[API_KEY_ENV]) {
						ctx.ui.notify(
							"API key is set via $LLAMA_SWAP_API_KEY. Unset the env var to edit it here.",
							"warning",
						);
						continue;
					}
					const v = await ctx.ui.input(
						"API key (empty = no auth, 'none' = clear)",
						current.apiKey ? maskKey(current.apiKey) : "",
					);
					if (v === undefined) continue;
					const newKey =
						v.trim().toLowerCase() === "none" || v.trim() === "" ? "" : v.trim();
					const updated = readSidecar();
					updated.apiKey = newKey;
					writeSidecar(updated);
					register(pi, current.url, newKey, updated);
					ctx.ui.notify(newKey ? "API key updated" : "API key cleared", "info");
				} else if (picked === testLine) {
					try {
						const ids = await fetchModelIds(current.url, current.apiKey);
						ctx.ui.notify(
							`✓ ${current.url} responded with ${ids.length} model(s)`,
							"info",
						);
					} catch (err) {
						ctx.ui.notify(
							`✗ ${current.url}: ${err instanceof Error ? err.message : String(err)}`,
							"error",
						);
					}
				} else if (picked === reloadLine) {
					try {
						const ids = await fetchModelIds(current.url, current.apiKey);
						const updated = readSidecar();
						updated.discoveredModels = ids;
						writeSidecar(updated);
						register(pi, current.url, current.apiKey, updated);
						ctx.ui.notify(`Reloaded ${ids.length} model(s) from ${current.url}`, "info");
					} catch (err) {
						ctx.ui.notify(
							`Reload failed: ${err instanceof Error ? err.message : String(err)}`,
							"error",
						);
					}
				} else if (picked === configureLine) {
					const ids = readSidecar().discoveredModels ?? [];
					if (ids.length === 0) {
						ctx.ui.notify("No models discovered yet. Reload first.", "warning");
						continue;
					}
					const modelId = await ctx.ui.select("Configure which model?", ids);
					if (!modelId) continue;
					await configureModel(pi, ctx, modelId);
				} else if (picked === logoutLine) {
					if (!scNow.baseUrl && !scNow.apiKey) {
						ctx.ui.notify("No stored credentials to clear.", "info");
						continue;
					}
					const ok = await ctx.ui.confirm(
						"Clear llama-swap credentials?",
						"Removes the stored URL + API key. Per-model overrides are kept.",
					);
					if (!ok) continue;
					const updated = readSidecar();
					delete updated.baseUrl;
					delete updated.apiKey;
					writeSidecar(updated);
					const fallback = resolveConfig(updated);
					register(
						pi,
						fallback.url,
						fallback.apiKey,
						fallback.source === "default"
							? { ...updated, discoveredModels: [] }
							: updated,
					);
					ctx.ui.notify("Cleared llama-swap credentials.", "info");
				}
			}
		},
	});

	// -- Footer status while a llama-swap model is active -------------------
	pi.on("model_select", async (event, ctx) => {
		if (event.model.provider === PROVIDER) {
			const { url } = resolveConfig(readSidecar());
			ctx.ui.setStatus("llama-swap", `🦙 ${hostport(url)}`);
		} else {
			ctx.ui.setStatus("llama-swap", undefined);
		}
	});

	// -- Context-overflow recovery -----------------------------------------
	pi.on("message_end", (event, ctx) => {
		const m = event.message;
		if (m.role !== "assistant") return;
		if (m.stopReason !== "error") return;
		if (m.provider !== PROVIDER && ctx.model?.provider !== PROVIDER) return;

		const err = m.errorMessage ?? "";
		if (err.includes("context_length_exceeded")) return;
		if (!LLAMA_CPP_OVERFLOW_PATTERNS.some((p) => p.test(err))) return;

		return {
			message: {
				...m,
				errorMessage: `context_length_exceeded: ${err}`,
			},
		};
	});
}
