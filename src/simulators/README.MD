# Seller Inventory Simulator API (F3)

Mock REST API for seller inventory simulation featuring pagination, rate limiting, bearer authentication, and fault injection (US-04).

##  How to Run Locally

### 1. Install Dependencies
\`\`\`bash
python3 -m pip install fastapi uvicorn
\`\`\`

### 2. Start the Server
Navigate to the module directory and start the Uvicorn server:
\`\`\`bash
cd src/simulators/inventory_api
python3 -m uvicorn main:app --reload
\`\`\`

The API will be available at: http://127.0.0.1:8000  
Interactive Swagger Documentation: http://127.0.0.1:8000/docs

---

##  Authentication & Test Credentials

The API enforces HTTP Bearer Authorization.

* **Header Format:** Authorization: Bearer <TOKEN>
* **Valid Test Tokens:**
  * token-seller-123
  * bearer-token-mercaandes-2026
  * test-token

---

##  Endpoint Details

### GET /api/v1/sellers/{seller_id}/inventory

Retrieves a paginated list of SKUs and available stock for a given seller.

#### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| seller_id | String (Path) | Yes | - | Target Seller Identifier (e.g., SELLER_001, seller_123) |
| page | Integer (Query) | No | 1 | Page number (Min: 1) |
| limit | Integer (Query) | No | 10 | Number of items per page (Min: 1, Max: 100) |

#### Sample Request (cURL)
\`\`\`bash
curl -X 'GET' \\
  'http://127.0.0.1:8000/api/v1/sellers/SELLER_001/inventory?page=1&limit=10' \\
  -H 'accept: application/json' \\
  -H 'Authorization: Bearer token-seller-123'
\`\`\`

#### Sample Response (200 OK)
\`\`\`json
{
  \"seller_id\": \"SELLER_001\",
  \"page\": 1,
  \"limit\": 10,
  \"total_items\": 25,
  \"total_pages\": 3,
  \"data\": [
    {
      \"sku\": \"SKU-00094\",
      \"quantity\": 75,
      \"updated_at\": \"2026-10-05T12:00:00Z\"
    },
    {
      \"sku\": \"SKU-00032\",
      \"quantity\": -3,
      \"updated_at\": \"2026-10-05T12:00:00Z\"
    }
  ]
}
\`\`\`

---

## ️ Resilience & Fault Simulation Behaviors

* **Intermittent Error Rate (>= 3%):** Intermittently responds with HTTP 429 Too Many Requests or 503 Service Unavailable to test downstream pipeline resilience.
* **Negative Stock Injection:** Injects negative stock quantities for anomaly testing (configurable via ENABLE_NEGATIVE_INVENTORY).
* **Environment Variables:**
  * ERROR_RATE: Error injection probability (default: 0.03).
  * ENABLE_NEGATIVE_INVENTORY: Enable negative stock generation (default: true).
'''

