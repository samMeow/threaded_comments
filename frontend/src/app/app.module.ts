import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { AppComponent } from './app.component';
import { ThreadModule } from './thread/thread.module';
import { ThreadComponent } from './thread/thread.component';
import { CommentModule } from './comment/comment.module';
import { CommentComponent } from './comment/comment.component';
import { UserModule } from './user/user.module';
import { UserService } from './user/user.service';
import { UserComponent } from './user/user.component';

@NgModule({
  declarations: [
    AppComponent,
    // UserComponent,
  ],
  imports: [
    BrowserModule,
    CommentModule,
    ThreadModule,
    UserModule,
    BrowserAnimationsModule,
    RouterModule.forRoot([
      { path: '', component: ThreadComponent },
      { path: 'threads/:threadId', component: CommentComponent },
    ]),
  ],
  // singleton
  providers: [UserService],
  bootstrap: [AppComponent]
})
export class AppModule { }
