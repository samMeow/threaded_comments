# Deep Nested Comments (Disqus like)
[Disqus Demo](https://about.disqus.com/disqus-demo-page).
In fact what imitate in this repository is only the comment list method, where most of the time we want to sort by parent comments only. 
(https://github.com/posativ/isso) has a more comprehensive implementation, but it doesn't include ordering and deep nested comments.

## Implementation
The core part for this ordered comment list relies on `path`, which record comments ancestors.  
We can make use of path which makes up of parent id, e.g.`1.10.123`.  
Notice that for serial id, we can get comment order by its root comments simply by ordering by path.  
For uuid id, we can use format like e.g. embedding timestamp at the front `2020-05-05T00:00:00Z-1.2020-05-05T00:00:00Z-10` or use subquery.
Meanwhile, ordering by path may usually treated as string, you may consider leftpad.

## API
GET /threads/:id
POST /threads { title: string }
PUT /threads { title: string }

GET /users/:id
POST /users { name: string }
PUT /users { name: string }

GET /comments/list { thread_id: string!; limit: string; offset: string; order: 'asc' | 'desc' }
GET /comments/listPopular { thread_id: string!; limit: string; offset: string; }
POST /comments { message: string!; thread_id: integer!; user_id: integer!; parent_id: integer }
POST /comments/:id/upvote
POST /comments/:id/downvotes

## Getting Started
```sh
bundle
bundle exec rackup
# test
rake spec
# integration test
/bin/bash ./integration_test
```