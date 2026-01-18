import os
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import requests
import base64
import json

app = FastAPI()

# Read the URL from Environment Variable (set in K8s ConfigMap)
# Fallback to localhost for local testing
KSERVE_URL = os.getenv("KSERVE_URL", "http://localhost:8080/v2/models/ocr-model/infer")

@app.post("/gateway/ocr")
async def gateway_ocr_request(image_file: UploadFile = File(...)):      
    try:
        image_data = await image_file.read()
        base64_image_data = base64.b64encode(image_data).decode('utf-8')

        infer_request = {
            "inputs": [
                {
                    "name": "input-0",
                    "shape": [1],
                    "datatype": "BYTES",
                    "data": [base64_image_data],
                    "parameters": {"content_type": image_file.content_type}
                }
            ]
        }

        headers = {'Content-Type': 'application/json'}
        response = requests.post(KSERVE_URL, headers=headers, data=json.dumps(infer_request))

        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail=response.text)

        return JSONResponse(content=response.json())

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)