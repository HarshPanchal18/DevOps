# Work(task) queue

The main idea behind Work Queues (aka: **Task Queues**) is to avoid doing a resource-intensive task immediately and having to wait for it to complete. Instead we schedule the task to be done later. We encapsulate a task as a message and send it to the queue.

A worker process running in the background will pop the tasks and eventually execute the job. When you run many workers the tasks will be shared between them.

This is useful in web applications where it's impossible to handle a complex task during a short HTTP request window.

One of the advantages of using a **Task Queue** is the ability to easily parallelise work. If we are building up a backlog of work, we can just add more workers and that way, scale easily.
