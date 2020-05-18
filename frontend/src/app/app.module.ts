import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';

import { AppComponent } from './app.component';
import { ThreadModule } from './thread/thread.module';
import { ThreadComponent } from './thread/thread.component';
import { CommentModule } from './comment/comment.module';
import { CommentComponent } from './comment/comment.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

@NgModule({
  declarations: [
    AppComponent,
  ],
  imports: [
    BrowserModule,
    CommentModule,
    ThreadModule,
    BrowserAnimationsModule,
    RouterModule.forRoot([
      { path: '', component: ThreadComponent },
      { path: 'threads/:threadId', component: CommentComponent },
    ]),
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
