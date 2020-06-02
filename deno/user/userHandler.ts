import {
  Router,
  Application,
  RouterContext,
} from "https://deno.land/x/oak/mod.ts";
import { onlyJson } from "../utils/middleware.ts";
import UserRepository from "./userRepository.ts";

const router = new Router();

export class UserHandler {
  constructor(private userRepo: UserRepository) {}

  getUsers = async (ctx: RouterContext) => {
    const result = await this.userRepo.getUsers();
    ctx.response.body = result;
  };

  getUser = async (ctx: RouterContext) => {
    const { id } = ctx.params;
    const result = await this.userRepo.getUser(Number(id));
    if (!result) {
      return ctx.throw(404, "User not found");
    }
    ctx.response.body = result;
  };

  createUser = async (ctx: RouterContext) => {
    const body = await ctx.request.body() as { value: { name?: string } };
    const { value: { name } } = body;
    // validation 
    if (!name || name.trim() === '') {
      ctx.throw(400, 'Missing name');
      return
    }
    const id = await this.userRepo.createUser(name);
    const user = await this.userRepo.getUser(Number(id));
    ctx.response.status = 201
    ctx.response.body = user;
  };
}

export default (app: Application, handler: UserHandler) => {
  router
    .get("/users", handler.getUsers)
    .get("/users/:id", handler.getUser)
    .post("/users", onlyJson, handler.createUser);
  app.use(router.routes());
};
