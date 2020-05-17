import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { MatListModule } from '@angular/material/list';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';


import { CommentComponent } from './comment.component';
import { CommentItemComponent } from './commentItem/commentItem.component';

@NgModule({
  declarations: [
    CommentComponent,
    CommentItemComponent,
  ],
  imports: [
    CommonModule,
    HttpClientModule,
    MatListModule,
    MatSelectModule,
    MatFormFieldModule,
    ReactiveFormsModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
  ],
  providers: [],
  exports: [CommentComponent]
})
export class CommentModule { }
