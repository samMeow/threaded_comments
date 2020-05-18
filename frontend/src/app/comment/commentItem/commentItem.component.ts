import { Component, Input, EventEmitter, Output, OnInit } from '@angular/core';
import { Subject } from 'rxjs';
import { scan, startWith, map, flatMap } from 'rxjs/operators';
import { FormBuilder } from '@angular/forms';

import { loadingObserver } from 'utils/loading';

import { CommentService } from '../comment.service';
import { Comment } from '../comment';


@Component({
  selector: 'app-comment-item',
  templateUrl: './commentItem.component.html',
  providers: [CommentService],
  styleUrls: ['./commentItem.component.css']
})
export class CommentItemComponent implements OnInit {
  @Input() comment: Comment;
  @Output() afterReply = new EventEmitter<Comment>();

  voteLoading = new Subject<boolean>();

  uiUpvote = new Subject<number>();
  uiDownvote = new Subject<number>();

  replyClick = new Subject();
  reset = new Subject();
  showReply$ = this.reset.asObservable()
    .pipe(startWith(false))
    .pipe(flatMap(() =>
      this.replyClick.asObservable()
        .pipe(startWith(false))
        .pipe(scan((last) => !last, false))
    ));

  combinedUpvote$ = this.uiUpvote.asObservable()
    .pipe(startWith(0))
    .pipe(
      scan((memo, c) => Math.max(memo, c))
    ).pipe(
      map(x => Math.max(x, this.comment.upvote))
    );

  combinedDownvote = this.uiDownvote.asObservable()
    .pipe(startWith(0))
    .pipe(
      scan((memo, c) => Math.max(memo, c))
    ).pipe(
      map(x => Math.max(x, this.comment.downvote))
    );

  replyForm = this.formBuilder.group({
    message: '',
  });

  paddingStyle = {};

  constructor(
    private commentService: CommentService,
    private formBuilder: FormBuilder,
  ) {}

  ngOnInit() {
    this.paddingStyle = { 'padding-left': `${Math.min(this.comment?.depth || 0, 3) * 2.5}rem` };
  }

  upvote(id: number) {
    this.commentService.upvote(id)
      .pipe(loadingObserver(this.voteLoading))
      .subscribe((result) => this.uiUpvote.next(result?.upvote || 0));
  }

  downvote(id: number) {
    this.commentService.downvote(id)
      .pipe(loadingObserver(this.voteLoading))
      .subscribe((result) => this.uiDownvote.next(result?.downvote || 0));
  }

  onReply({ message }: { message: string }) {
    this.commentService.create(
      this.comment.thread_id,
      1,
      message,
      this.comment.id,
    ).subscribe((result) => {
      this.replyForm.reset();
      this.afterReply.emit(result);
      this.reset.next();
    });
  }
}
