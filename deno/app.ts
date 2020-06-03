import { Application } from "https://deno.land/x/oak/mod.ts";
import { container } from "https://deno.land/x/alosaur/mod.ts";

import handler, { UserHandler } from "./user/userHandler.ts";
import UserRepository from './user/userRepository.ts';
import { errorHandle } from "./utils/middleware.ts";
import { createPool } from "./db.ts";

const db = await createPool();
container.register("Pool", { useValue: db });
container.register('IUserRepository', { useClass: UserRepository });

const app = new Application();

app.use(errorHandle);
handler(app, container.resolve<UserHandler>(UserHandler));

await app.listen({ port: 8000 });
