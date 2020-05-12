import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { MatListModule } from '@angular/material/list';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';


import { CommentComponent } from './comment.component';

@NgModule({
  declarations: [
    CommentComponent,
  ],
  imports: [
    CommonModule,
    HttpClientModule,
    MatListModule,
    MatSelectModule,
    MatFormFieldModule,
  ],
  providers: [],
  exports: [CommentComponent]
})
export class CommentModule { }
