import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders, HttpErrorResponse } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';

import { environment } from 'environments/environment';

import { ListResponse, Comment } from './comment';

const handleError = <T>(result = {} as T) => (err: HttpErrorResponse) => {
  console.error(err);
  return of(result);
};

@Injectable()
export default class CommentService {
  baseUrl = environment.commentAPIUrl;

  constructor(private http: HttpClient) {}

  getList(
      threadId: number,
      limit: number = 20,
      offset: number = 0,
      order: 'asc' | 'desc' = 'asc'
  ): Observable<ListResponse<Comment>> {
    const params = new HttpParams({
      fromObject: {
        thread_id: String(threadId),
        limit: String(limit),
        offset: String(offset),
        order,
      },
    });
    return this.http.get<ListResponse<Comment>>(
      `${this.baseUrl}/comments/list`,
      { params },
    ).pipe(
      catchError(
        handleError({ meta: { has_next_page: false }, data: [] })
      )
    );
  }

  getPopular(
    threadId: number,
    limit: number = 20,
    offset: number = 0,
  ): Observable<ListResponse<Comment>> {
    const params = new HttpParams({
      fromObject: {
        thread_id: String(threadId),
        limit: String(limit),
        offset: String(offset),
      }
    });
    return this.http.get<ListResponse<Comment>>(
      `${this.baseUrl}/comments/listPopular`,
      { params },
    ).pipe(
      catchError(
        handleError({ meta: { has_next_page: false }, data: [] })
      )
    );
  }

  create(
    threadId: number,
    userId: number,
    message: string,
    parentId?: string,
  ): Observable<Comment> {
    return this.http.post<Comment>(
      `${this.baseUrl}/comments`,
      {
        thread_id: threadId,
        user_id: userId,
        message,
        ...(parentId && { parent_id: parentId }),
      },
      {
        headers: new HttpHeaders({
          'Content-Type': 'application/json',
        }),
      }
    ).pipe(catchError(handleError(null)));
  }

  upvote(commentId: string): Observable<Comment> {
    return this.http.post<Comment>(
      `${this.baseUrl}/comments/${commentId}/upvote`,
      {}
    ).pipe(catchError(handleError(null)));
  }

  downvote(commentId: string): Observable<Comment> {
    return this.http.post<Comment>(
      `${this.baseUrl}/comments/${commentId}/downvote`,
      {}
    ).pipe(catchError(handleError(null)));
  }
}
