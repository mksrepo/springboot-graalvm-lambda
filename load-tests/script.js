// ============================================================================
// K6 Load Test Script
//
// Tests the full Product API lifecycle:
// 1. Create Product (POST)
// 2. Get Product by ID (GET)
// 3. List Products (GET)
// 4. Get Audit Logs (GET)
// ============================================================================

import http from "k6/http";
import { check, sleep } from "k6";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";

// --- Configuration ---
export let options = {
  vus: 10,       // Virtual Users
  duration: "10s", // Test Duration
  thresholds: {
    http_req_failed: ['rate<0.01'],   // Error rate should be < 1%
    http_req_duration: ['p(95)<500'], // 95% of requests should be faster than 500ms
  },
};

const BASE_URL = __ENV.URL; // e.g., http://localhost:30001/api/products
const AUDIT_URL = BASE_URL.replace("/products", "/audit-logs");
const HEADERS = { 'Content-Type': 'application/json' };

// --- Main Test Loop ---
export default function () {
  const productStub = generateProductPayload();

  // 1. Create Product
  const productId = createProduct(productStub);

  // 2. Get Product (if creation succeeded)
  if (productId) {
    getProductById(productId, productStub.name);
  }

  // 3. List All Products
  listProducts();

  // 4. View Audit Logs
  getAuditLogs();

  // 5. Think Time (random sleep between 0.1s and 0.6s)
  sleep(Math.random() * 0.5 + 0.1);
}

// --- Helper Functions ---
function generateProductPayload() {
  const randomId = Math.floor(Math.random() * 100000);
  return {
    name: `Load Test Product ${randomId}`,
    description: "Created by K6 Load Test",
    price: parseFloat((Math.random() * 100).toFixed(2)),
    quantity: Math.floor(Math.random() * 100)
  };
}

function createProduct(payload) {
  const res = http.post(BASE_URL, JSON.stringify(payload), { headers: HEADERS });

  check(res, {
    "POST /products 201 Created": (r) => r.status === 201,
  });

  try {
    return res.json('id');
  } catch (e) {
    return null; // Return null if response isn't JSON
  }
}

function getProductById(id, expectedName) {
  const res = http.get(`${BASE_URL}/${id}`, { headers: HEADERS });

  check(res, {
    "GET /products/:id 200 OK": (r) => r.status === 200,
    "GET /products/:id matches name": (r) => r.json('name') === expectedName,
  });
}

function listProducts() {
  const res = http.get(BASE_URL, { headers: HEADERS });

  check(res, {
    "GET /products 200 OK": (r) => r.status === 200,
    "GET /products has body": (r) => r.body.length > 0,
  });
}

function getAuditLogs() {
  const res = http.get(AUDIT_URL, { headers: HEADERS });

  check(res, {
    "GET /audit-logs 200 OK": (r) => r.status === 200,
  });
}

// --- Custom Reporting ---
export function handleSummary(data) {
  // Output report to a file based on the environment (AOT or JIT)
  const reportPath = `./report/k6_report_${__ENV.TYPE}.txt`;
  return {
    stdout: textSummary(data, { indent: " ", enableColors: true }), // Print to console
    [reportPath]: textSummary(data, { indent: " ", enableColors: false }), // Save to file
  };
}