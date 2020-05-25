import { NgModule } from '@angular/core';

import { HttpClientModule } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';

import { UserComponent } from './user.component';

@NgModule({
  declarations: [UserComponent],
  imports: [
    CommonModule,
    HttpClientModule,
    MatSelectModule,
    MatFormFieldModule,
    ReactiveFormsModule,
    MatInputModule,
    MatButtonModule,
  ],
  providers: [],
  exports: [UserComponent]
})
export class UserModule {}
