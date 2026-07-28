/** @jsxImportSource @opentui/solid */
import { Show, createMemo } from "solid-js";
import type { AssistantMessage } from "@opencode-ai/sdk/v2";
import type {
  TuiPlugin,
  TuiPluginModule,
  TuiSlotPlugin,
} from "@opencode-ai/plugin/tui";

const tui: TuiPlugin = async (api) => {
  const slotPlugin: TuiSlotPlugin = {
    order: 100,
    slots: {
      session_prompt_right(ctx, props) {
        const metrics = createMemo(() => {
          const messages = api.state.session.messages(props.session_id) ?? [];
          const last = messages.findLast(
            (m): m is AssistantMessage => m.role === "assistant",
          );
          if (!last) return "";

          const parts = api.state.part(last.id) ?? [];
          let first = Infinity;
          let active = 0;
          for (const part of parts) {
            if (part.type !== "text" && part.type !== "reasoning") continue;
            const { start, end } = part.time ?? {};
            if (typeof start !== "number") continue;
            if (start < first) first = start;
            if (typeof end === "number" && end > start) active += end - start;
          }
          if (!Number.isFinite(first)) return "";
          const ttft = `${(Math.max(0, first - last.time.created) / 1000).toFixed(2)}s ttft`;

          const tokens = last.tokens.output + last.tokens.reasoning;
          if (!last.time.completed || tokens === 0) return ttft;
          const span = active > 0 ? active : last.time.completed - first;
          const tps = tokens / Math.max(span / 1000, 0.001);
          return `${ttft} · ${tps.toFixed(1)} tok/s`;
        });
        return (
          <Show when={metrics()}>
            <text fg={ctx.theme.current.textMuted} wrapMode="none">
              {metrics()}
            </text>
          </Show>
        );
      },
    },
  };
  api.slots.register(slotPlugin);
};

const plugin: TuiPluginModule & { id: string } = {
  id: "metrics",
  tui,
};

export default plugin;
