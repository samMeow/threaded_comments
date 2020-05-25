import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpErrorResponse } from '@angular/common/http';
import { Observable, of, BehaviorSubject } from 'rxjs';
import { catchError, shareReplay } from 'rxjs/operators';

import { environment } from 'environments/environment';

import { User } from './user';

const handleError = <T>(result = {} as T) => (err: HttpErrorResponse) => {
  console.error(err);
  return of(result);
};

@Injectable()
export class UserService {
  baseUrl = environment.commentAPIUrl;

  currentUser = new BehaviorSubject<User>(null);
  currentUser$ = this.currentUser.asObservable().pipe(shareReplay(1));

  constructor(private http: HttpClient) {}

  getList(): Observable<User[]> {
    return this.http.get<User[]>(
      `${this.baseUrl}/users`
    ).pipe(catchError(handleError([])));
  }

  createUser(name: string): Observable<User> {
    return this.http.post<User>(
      `${this.baseUrl}/users`,
      { name },
      { headers: new HttpHeaders({ 'Content-Type': 'application/json' }) },
    ).pipe(catchError(handleError(null)));
  }

  changeUser(user: User) {
    this.currentUser.next(user);
  }
}
