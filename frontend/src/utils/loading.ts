import { Observable, Subject, defer } from 'rxjs';
import { finalize } from 'rxjs/operators';

export const before = (callback: () => void) => <T>(source: Observable<T>): Observable<T> => {
  return defer(() => {
    callback();
    return source;
  });
};

export const loadingObserver = (sub: Subject<boolean>) => <T>(source: Observable<T>): Observable<T> => {
  return source.pipe(
    before(() => sub.next(true)),
    finalize(() => sub.next(false)),
  );
};
