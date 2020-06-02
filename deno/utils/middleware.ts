import {
  RouterContext,
  Context,
  isHttpError,
} from "https://deno.land/x/oak/mod.ts";

export const onlyJson = async (
  ctx: RouterContext,
  next: () => Promise<void>,
) => {
  const contentType = ctx.request.headers.get("content-type");
  if (contentType !== "application/json") {
    ctx.throw(400, "This endpoint only allow json content");
    return;
  }
  await next();
};

export const errorHandle = async (ctx: Context, next: () => Promise<void>) => {
  try {
    await next();
  } catch (e) {
    if (isHttpError(e)) {
      ctx.response.status = e.status;
      ctx.response.body = {
        code: e.status,
        message: e.message,
      };
      return;
    }
    ctx.response.status = 500;
    ctx.response.body = {
      code: 500,
      message: "oops wrong",
    };
    console.log(e);
  }
};
