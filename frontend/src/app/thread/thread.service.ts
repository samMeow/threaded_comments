import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpErrorResponse } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';

import { environment } from 'environments/environment';

import { Thread } from './thread';

const handleError = <T>(result = {} as T) => (err: HttpErrorResponse) => {
  console.error(err);
  return of(result);
};

@Injectable()
export class ThreadService {
  baseUrl = environment.commentAPIUrl;

  constructor(private http: HttpClient) {}

  getList(): Observable<Thread[]> {
    return this.http.get<Thread[]>(
      `${this.baseUrl}/threads`,
    ).pipe(
      catchError(
        handleError([])
      )
    );
  }

  getDetail(id: number): Observable<Thread> {
    return this.http.get<Thread>(
      `${this.baseUrl}/threads/${id}`,
    ).pipe(catchError(handleError(null)));
  }

  create(title: string) {
    return this.http.post<Thread>(
      `${this.baseUrl}/threads`,
      { title },
      {
        headers: new HttpHeaders({
          'Content-Type': 'application/json',
        }),
      }
    ).pipe(catchError(handleError(null)));
  }
}
