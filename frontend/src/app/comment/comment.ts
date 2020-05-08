export interface ListResponse<T> {
  meta: { has_next_page: boolean };
  data: T[];
}

export interface Comment {
  id: number;
  thread_id: number;
  user_id: number;
  parent_id: null | number;
  message: string;
  depth: number;
  score: number;
  upvote: number;
  downvote: number;
  create_time: string;
}