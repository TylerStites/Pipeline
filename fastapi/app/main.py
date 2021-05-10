from elasticsearch import Elasticsearch
from fastapi_elasticsearch.utils import wait_elasticsearch
from fastapi import Depends, FastAPI
from fastapi.responses import JSONResponse
from typing import Dict, Optional



es = Elasticsearch(
    ["172.18.0.4:9200"],
    # port=9200,
    use_ssl=False,
    ssl_show_warn=False
)

wait_elasticsearch(es)

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Optional[str] = None):
    return {"item_id": item_id, "q": q}

# Create a route using the query builder as dependency.
@app.get("/search/koyfin_unadjusted_price")
async def search() -> JSONResponse:
    # Search using the Elasticsearch client.
    return es.search(
        body={ "query": {
                    "match_all": {}
                    }
            },
        index="koyfin_unadjusted_price"
    )

# Create a route using the query builder as dependency.
@app.get("/search/koyfin_adjusted_price")
async def search() -> JSONResponse:
    # Search using the Elasticsearch client.
    return es.search(
        body={ "query": {
                    "match_all": {}
                    }
            },
        index="koyfin_adjusted_price"
    )