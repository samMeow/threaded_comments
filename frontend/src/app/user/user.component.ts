import { Component, OnInit } from '@angular/core';
import { FormBuilder } from '@angular/forms';

import { UserService } from './user.service';
import { User } from './user';

@Component({
  selector: 'app-user',
  templateUrl: './user.component.html',
  providers: [],
  styleUrls: ['./user.component.css']
})
export class UserComponent implements OnInit {
  users: User[] = [];

  userForm = this.formBuilder.group({
    name: ''
  });

  currentUser$ = this.userService.currentUser$;

  constructor(
    private userService: UserService,
    private formBuilder: FormBuilder,
  ) {}

  ngOnInit() {
    this.refreshList();
  }

  refreshList() {
    this.userService.getList().subscribe((result) => {
      this.users = result;
    });
  }

  createUser({ name }: { name: string }) {
    return this.userService.createUser(name)
      .subscribe(() => {
        this.refreshList();
        this.userForm.reset();
      });
  }

  changeUser({ value }: { value: number }) {
    this.userService.changeUser(this.users.find(x => x.id === value));
  }
}
