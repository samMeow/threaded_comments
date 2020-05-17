import { Component, OnInit, Input } from '@angular/core';
import { FormBuilder } from '@angular/forms';
import { Subject, Observable, combineLatest, BehaviorSubject } from 'rxjs';
import { startWith, concatMap, scan, flatMap, share, map } from 'rxjs/operators';

import { loadingObserver } from 'utils/loading';
import findLastIndex from 'utils/findLastIndex';
import rightMerge from 'utils/rightMerge';

import { CommentService } from './comment.service';
import { Comment, ListResponse } from './comment';

const PAGE_SIZE = 5;
@Component({
  selector: 'app-comments',
  providers: [CommentService],
  templateUrl: './comment.component.html',
  styleUrls: ['./comment.component.css'],
})
export class CommentComponent implements OnInit {
  @Input() threadId: number;
  allowedSorting = [
    { value: 'list_desc', label: 'From new to old' },
    { value: 'list_asc', label: 'From old to new' },
    { value: 'list_popular', label: 'Sort by popularity' }
  ];
  sortChange = new BehaviorSubject(this.allowedSorting[0]);
  sortChange$ = this.sortChange.asObservable();

  loadMoreClick = new Subject();
  loadMoreClick$ = this.loadMoreClick.asObservable();

  loading$ = new BehaviorSubject(false);


  comments$ = new Observable<Comment[]>();
  canLoadMore$ = new Observable<boolean>();

  uiComments = new BehaviorSubject<Comment[]>([]);
  uiComments$ = this.uiComments.asObservable();

  newCommentForm = this.formBuilder.group({
    message: ''
  });

  constructor(
    private commentService: CommentService,
    private formBuilder: FormBuilder,
  ) {}

  ngOnInit() {
    const listStream = this.sortChange$
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
              data: rightMerge(memo.data, res.data, ({ id }) => String(id)),
            }), { has_next_page: false, data: [] as Comment[] })
          )
      ))
      .pipe(share());
    const tempComments = this.sortChange$
      .pipe(flatMap(() =>
        this.uiComments$
          .pipe(scan((memo, res) => memo.concat(res), [] as Comment[]))
      ));
    // sortStream.subscribe(console.log)
    this.comments$ = combineLatest([tempComments, listStream])
      .pipe(
        map(([ui, { data }]) => {
          if (ui.length === 0) {
            return data;
          }
          return ui.reduce((memo, c) => {
            if (memo.find(x => x.id === c.id)) {
              return memo;
            }
            if (c.parent_id === null) {
              return [c, ...memo];
            }
            const parent = memo.findIndex(p => p.id === c.parent_id);
            const lastChild = findLastIndex(memo, child => child.parent_id === c.parent_id);
            const temp = [...memo];
            temp.splice(Math.max(parent, lastChild) + 1, 0, c);
            return temp;
          }, data);
        })
      );
    this.canLoadMore$ = listStream
      .pipe(map(({has_next_page}) => has_next_page));
  }

  postComment({ message }: { message: string }) {
    this.commentService.create(this.threadId, 1, message)
      .subscribe((result) => {
        this.newCommentForm.reset();
        this.uiComments.next([result]);
      });
  }

  afterReply(comment: Comment) {
    this.uiComments.next([comment]);
  }
}
