import { z } from "zod";
import { Hono } from "hono";
import bcrypt from "bcryptjs";
import { eq } from "drizzle-orm";
import { zValidator } from "@hono/zod-validator";

import { db } from "@/db/drizzle";
import { users } from "@/db/schema";

const generateId = () => crypto.randomUUID();

const app = new Hono()
  .post(
    "/",
    zValidator(
      "json",
      z.object({
        name: z.string(),
        email: z.string().email(),
        password: z.string().min(3).max(20),
      })
    ),
    async (c) => {
      const { name, email, password } = c.req.valid("json");

      try {
        // Check for duplicate email BEFORE expensive bcrypt hash
        const existing = await db
          .select()
          .from(users)
          .where(eq(users.email, email));

        if (existing[0]) {
          return c.json({ error: "Email already in use" }, 400);
        }

        const hashedPassword = await bcrypt.hash(password, 12);

        await db.insert(users).values({
          id: generateId(),
          email,
          name,
          password: hashedPassword,
        });

        return c.json(null, 200);
      } catch (error) {
        console.error("[v0] Sign-up error:", error);
        return c.json({ error: "Internal server error" }, 500);
      }
    },
  );

export default app;
