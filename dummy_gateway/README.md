Dummy gateway
============

Dummy gateway application that receives a GET request at:

`/submit_job/<job_id>`

and creates an output on object store of Jetstream.

The docker container needs to be built locally in order to copy the credentials
necessary to write to object store.

The purpose of this is to demonstrate how from a Notebook running
on Jetstream you can interactively submit a job to a gateway with `requests` and
then get the results from object store
