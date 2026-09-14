import { expect, test } from "bun:test";
import app from "./app";

test("GET / returns Hello Hono!", async () => {
	const response = await app.request("/");

	expect(response.status).toBe(200);
	expect(await response.text()).toBe("Hello Hono!");
});
