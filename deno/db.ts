import { Pool } from "https://deno.land/x/postgres/mod.ts";

// config can read from env https://github.com/deno-postgres/deno-postgres/blob/788f7b2ea5/connection_params.ts
const createPool = async () => {
  const pool = new Pool({
    user: "postgres",
    password: "example",
    database: "comment-demo",
    hostname: "127.0.0.1",
    port: 5433,
  }, 4);
  await pool.connect();
  return pool;
};

export { createPool };
