import { Component, OnInit, Input } from '@angular/core';
import { Subject, Observable } from 'rxjs';
import { startWith, concatMap, scan, map, flatMap, share } from 'rxjs/operators';

import { loadingObserver } from 'utils/loading';

import CommentService from './comment.service';
import { Comment, ListResponse } from './comment';

const PAGE_SIZE = 5;
@Component({
  selector: 'app-comments',
  providers: [CommentService],
  templateUrl: './comment.component.html',
  styles: ['./comment.component.css'],
})
export class CommentComponent implements OnInit {
  @Input() threadId: number;
  allowedSorting = [
    { value: 'list_desc', label: 'From new to old' },
    { value: 'list_asc', label: 'From old to new' },
    { value: 'list_popular', label: 'Sort by popularity' }
  ];
  sortChange = new Subject();
  sortChange$ = this.sortChange.asObservable();

  loadMoreClick = new Subject();
  loadMoreClick$ = this.loadMoreClick.asObservable();
  showLoadMore$ = new Observable<boolean>();

  loading$ = new Subject<boolean>();
  comments: Observable<Comment[]>;

  constructor(private commentService: CommentService) {}

  ngOnInit() {
    const listStream = this.sortChange$
      .pipe(startWith({ value: 'list_desc' }))
      .pipe(flatMap(({ value }) =>
        this.loadMoreClick$
          .pipe(startWith(0))
          .pipe(concatMap(
            (_, index) => {
              const fnDict: {[key: string]: () => Observable<ListResponse<Comment>>} = {
                list_desc: this.commentService.getList.bind(this.commentService, this.threadId, PAGE_SIZE, PAGE_SIZE * index, 'desc'),
                list_asc: this.commentService.getList.bind(this.commentService, this.threadId, PAGE_SIZE, PAGE_SIZE * index, 'asc'),
                list_popular: this.commentService.getPopular.bind(this.commentService, this.threadId, PAGE_SIZE, PAGE_SIZE * index),
              };
              return fnDict[value]().pipe(loadingObserver(this.loading$));
            }
          ))
          .pipe(
            scan((memo, res) => ({
              has_next_page: res.meta.has_next_page,
              data: memo.data.concat(res.data),
            }), { has_next_page: false, data: [] })
          )
      ))
      .pipe(share());
    this.comments = listStream.pipe(
      map(v => v.data)
    );
    this.showLoadMore$ = listStream.pipe(map(v => v.has_next_page));
  }
}
