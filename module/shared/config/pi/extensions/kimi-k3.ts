import { readFileSync } from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function read(path: string): string {
  return readFileSync(path, "utf8").trim();
}

export default function (pi: ExtensionAPI) {
  try {
    pi.registerProvider("kimi-k3", {
      name: "Kimi K3",
      baseUrl: read("/run/agenix/modal-url-kimi-k3"),
      api: "openai-completions",
      authHeader: true,
      apiKey: "dummy",
      headers: {
        "Modal-Key": read("/run/agenix/modal-token-id"),
        "Modal-Secret": read("/run/agenix/modal-token-secret"),
      },
      models: [
        {
          id: "moonshotai/Kimi-K3",
          name: "Kimi K3",
          reasoning: true,
          thinkingLevelMap: {
            minimal: null,
            medium: null,
            xhigh: null,
            max: "max",
          },
          input: ["text"],
          cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
          contextWindow: 1048576,
          maxTokens: 131072,
        },
      ],
    });
  } catch {}
}
