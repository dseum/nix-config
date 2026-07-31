import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	const KEY = "metrics";
	let t0 = 0;
	let tFirst = 0;

	pi.on("turn_start", (event, ctx) => {
		t0 = event.timestamp;
		tFirst = 0;
		ctx.ui.setStatus(KEY, undefined);
	});

	pi.on("message_update", (event, ctx) => {
		if (tFirst) return;
		const { type } = event.assistantMessageEvent;
		if (type.startsWith("text_") || type.startsWith("thinking_")) {
			tFirst = Date.now();
			ctx.ui.setStatus(KEY, `${((tFirst - t0) / 1000).toFixed(2)}s ttft`);
		}
	});

	pi.on("message_end", (event, ctx) => {
		const message = event.message;
		if (message.role !== "assistant" || !tFirst) return;
		const ttft = `${((tFirst - t0) / 1000).toFixed(2)}s ttft`;
		const completed =
			message.stopReason === "stop" || message.stopReason === "length" || message.stopReason === "toolUse";
		const output = message.usage?.output ?? 0;
		if (!completed || output <= 0) {
			ctx.ui.setStatus(KEY, ttft);
			return;
		}
		const tps = output / Math.max((Date.now() - tFirst) / 1000, 0.001);
		ctx.ui.setStatus(KEY, `${ttft} · ${tps.toFixed(1)} tok/s`);
	});
}
