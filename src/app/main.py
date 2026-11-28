from fastapi import FastAPI

from app.api import health

app = FastAPI(title="AI Incident & Bug Triage")
app.include_router(health.router)
