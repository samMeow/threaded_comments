import { Pool } from "https://deno.land/x/postgres/mod.ts";
import { Injectable, Inject, container } from "https://deno.land/x/alosaur/mod.ts";

type User = {
  id: number;
  name: string;
  create_time: string;
};

export interface IUserRepository {
  getUsers: () => Promise<User[]>;
  getUser: (id: number) => Promise<User | null>;
  createUser: (name: string) => Promise<string>;
}

@Injectable()
class UserRepository implements IUserRepository {
  constructor(@Inject("Pool") private client: Pool) {}

  async getUsers(): Promise<User[]> {
    const result = await this.client.query("SELECT * from users");
    return result.rowsOfObjects() as User[];
  }

  async getUser(id: number): Promise<User | null> {
    const result = await this.client.query(
      "SELECT * from users where id = $1",
      id,
    );
    return result.rowsOfObjects()[0] as User || null;
  }

  async createUser(name: string): Promise<string> {
    const result = await this.client.query(
      "INSERT INTO users (name) VALUES ($1) RETURNING id;",
      name,
    );
    return result.rows[0];
  }
}

export default UserRepository
