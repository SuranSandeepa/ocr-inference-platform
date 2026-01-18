import io
import time
import base64
from typing import Dict
from PIL import Image
import pytesseract
import kserve
from kserve import Model, ModelServer, InferRequest, InferResponse, InferInput, InferOutput
from kserve.utils.utils import generate_uuid
from prometheus_client import Histogram, Counter

# We use v4 in the name so we can verify it in the logs
REQUEST_COUNT = Counter('ocr_v4_total', 'Total OCR requests', ['status'])
PREDICT_LATENCY = Histogram('ocr_v4_latency_seconds', 'Inference latency')

class OCRModel(Model):
    def __init__(self, name: str):
        super().__init__(name)
        self.name = name
        self.ready = True 

    async def predict(self, infer_request: InferRequest, headers: Dict[str, str] = None) -> InferResponse:
        start_time = time.time()
        try:
            input_tensor = infer_request.inputs[0]
            base64_image_data = input_tensor.data[0] 
            image_data = base64.b64decode(base64_image_data)
            
            image = Image.open(io.BytesIO(image_data))
            extracted_text = pytesseract.image_to_string(image)

            REQUEST_COUNT.labels(status="success").inc()
            PREDICT_LATENCY.observe(time.time() - start_time)

            return InferResponse(
                model_name=self.name,
                infer_outputs=[
                    InferOutput(name="output-0", shape=[1], datatype="BYTES", data=extracted_text)
                ],
                response_id=generate_uuid()
            )
        except Exception as e:
            REQUEST_COUNT.labels(status="error").inc()
            raise e

if __name__ == "__main__":
    model = OCRModel("ocr-model")
    ModelServer().start([model])