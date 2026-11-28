from fastapi import FastAPI

app = FastAPI(title="AI Incident & Bug Triage")


@app.get("/health")
def health() -> dict[str, str]:
    """Report that the service is up."""
    return {"status": "ok"}
