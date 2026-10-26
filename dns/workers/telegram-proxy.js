// Telegram Bot API proxy for Gatus on zelda: api.telegram.org is blocked from its network.
// Only sendMessage of the Sogeor status bot is forwarded; everything else is refused,
// so this is not an open proxy. Nothing is logged: the path contains the bot token.
export default {
  async fetch(request, env) {
    const { pathname } = new URL(request.url);
    const allowed = new RegExp(`^/bot${env.BOT_ID}:[A-Za-z0-9_-]{30,}/sendMessage$`);
    if (request.method !== "POST" || !allowed.test(pathname)) {
      return new Response("Forbidden\n", { status: 403 });
    }
    return fetch(new URL(pathname, "https://api.telegram.org"), {
      method: "POST",
      headers: { "content-type": request.headers.get("content-type") ?? "application/json" },
      body: request.body,
    });
  },
};
