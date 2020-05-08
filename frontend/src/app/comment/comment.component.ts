import { Component, OnInit, Input } from '@angular/core';
import { Subject } from 'rxjs';

import { loadingObserver } from 'utils/loading';

import CommentService from './comment.service';
import { Comment } from './comment'

const PAGE_SIZE = 20;
@Component({
  selector: 'app-comments',
  providers: [CommentService],
  templateUrl: './comment.component.html',
  styles: [],
})
export class CommentComponent implements OnInit {
  @Input() thread_id: number;

  loading$ = new Subject<boolean>();
  comments: Comment[] = [];

  constructor(private commentService: CommentService) {}

  ngOnInit() {
    this.getList();
  }

  getList() {
    this.commentService.getList(this.thread_id, PAGE_SIZE, 0)
      .pipe(loadingObserver(this.loading$))
      .subscribe(({ meta, data }) => {
        this.comments = data;
      })
  }
}