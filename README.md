# Threaded Comments
Why? TL; DR, Just for Fun.  
Well I just want to try building a modern comment system, either deep nested or facebook like. 
Therefore, I try to imitate them while remain high response time as them even in large scale system.  
Here may not be the prefect implementation, but I hope it can give you insight in solving similar problem.

## Getting started
Docker-compose, docker
```sh
docker-compose up
# deep nested comment server is will be in 127.0.0.1:4567
```

## Deep Nested Comments (Disqus like)
In case, you don't know [Disqus Demo](https://about.disqus.com/disqus-demo-page).
For this I have implement the comment list API in ruby which you will find more information inside. 


## REFERENCES
[https://stackoverflow.com/questions/603894/is-postgresqls-ltree-module-a-good-fit-for-threaded-comments]
[https://www.postgresql.org/docs/9.2/ltree.html]
[https://coderwall.com/p/whf3-a/hierarchical-data-in-postgres]
[https://stackoverflow.com/questions/2797720/sorting-tree-with-a-materialized-path]
[http://www.dbazine.com/oracle/or-articles/tropashko4/]
[https://disqus.com/api/docs/threads/list/]