import { Component, Input, EventEmitter, Output } from '@angular/core';
import { Subject } from 'rxjs';
import { scan, startWith, map } from 'rxjs/operators';
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
export class CommentItemComponent {
  @Input() comment: Comment;
  @Output() afterReply = new EventEmitter<Comment>();

  voteLoading = new Subject<boolean>();

  uiUpvote = new Subject<number>();
  uiDownvote = new Subject<number>();

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

  constructor(
    private commentService: CommentService,
    private formBuilder: FormBuilder,
  ) {}

  upvote(id: number) {
    this.commentService.upvote(id)
      .pipe(loadingObserver(this.voteLoading))
      .subscribe((result) => this.uiUpvote.next(result?.upvote || 0));
  }

  downvote(id: number) {
    this.commentService.downvote(id)
      .pipe(loadingObserver(this.voteLoading))
      .subscribe((result) => this.uiDownvote.next(result?.downvote || 0))
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
    });
  }
}
