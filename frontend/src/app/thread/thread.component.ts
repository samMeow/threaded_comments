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

constructor(private threadService: ThreadService, private formBuilder: FormBuilder) {}

  threads = [];

  newThreadForm = this.formBuilder.group({
    title: '',
  });

  ngOnInit() {
    this.threadService.getList().subscribe((result) => {
      this.threads = result;
    });
  }

  createThread({ title }: { title: string }) {
    
  }
}

