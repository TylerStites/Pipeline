After running the koyfin install and start commands you will run the rebuild_run.sh script.

./rebuild_run.sh


That will show the container named fastapi is running using the docker ps -a command.
Next hit the endpoints to see the elasticsearch data that was written by spark using the zeppelin notebook.

http://localhost/search/koyfin_unadjusted_price
http://localhost/search/koyfin_adjusted_price