from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.auth_api import router as auth_router
from app.api.scan_api import router as scan_router
from app.api.inventory_api import router as inventory_router
from app.api.chat_api import router as chat_router

app = FastAPI(
    title="NoFTe API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(scan_router)
app.include_router(inventory_router)
app.include_router(chat_router)

@app.get("/")
def root():
    return {
        "message": "NoFTe Backend Running"
    }
