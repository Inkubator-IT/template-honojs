import app from "./app";

export default {
	port: Number(Bun.env.APP_PORT) || 3000,
	fetch: app.fetch,
};
