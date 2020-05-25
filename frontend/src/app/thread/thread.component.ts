import { Component, OnInit } from '@angular/core';
import { FormBuilder } from '@angular/forms';

import { ThreadService } from './thread.service';

@Component({
  selector: 'app-thread',
  templateUrl: './thread.component.html',
  providers: [ThreadService],
  styleUrls: ['./thread.component.css'],
})
export class ThreadComponent implements OnInit {

constructor(
  private threadService: ThreadService,
  private formBuilder: FormBuilder,
) {}

  threads = [];

  newThreadForm = this.formBuilder.group({
    title: '',
  });

  ngOnInit() {
    this.refreshList();
  }

  refreshList() {
    this.threadService.getList().subscribe((result) => {
      this.threads = result;
      this.newThreadForm.reset();
    });
  }

  createThread({ title }: { title: string }) {
    this.threadService.create(title)
      .subscribe(() => {
        this.refreshList();
      });
  }
}

