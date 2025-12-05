// Load test script for Spring Boot application
import http from "k6/http";
import { check, sleep } from "k6";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";

// Load environment variables
export let options = {
  vus: 10,
  duration: "10s"
};

export default function () {
  // 1. Create a Product (POST)
  const randomId = Math.floor(Math.random() * 1000);
  const payload = JSON.stringify({
    name: `Load Test Product ${randomId}`,
    description: "Created by K6",
    price: 99.99,
    quantity: 100
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const postRes = http.post(__ENV.URL, payload, params);

  check(postRes, {
    "POST status is 201": (r) => r.status === 201,
  });

  let productId;
  try {
    productId = postRes.json('id');
  } catch (e) {
    // ignore
  }

  // 2. Get Product by ID (GET)
  if (productId) {
    const getByIdRes = http.get(`${__ENV.URL}/${productId}`);
    check(getByIdRes, {
      "GET by ID status is 200": (r) => r.status === 200,
      "GET by ID has correct name": (r) => r.json('name') === `Load Test Product ${randomId}`,
    });
  }

  // 3. List Products (GET)
  const getRes = http.get(__ENV.URL);

  check(getRes, {
    "GET status is 200": (r) => r.status === 200,
    "Response has body": (r) => r.body.length > 0,
  });

  // 4. Get Audit Logs (GET)
  const auditLogUrl = __ENV.URL.replace("/products", "/audit-logs");
  const getAuditRes = http.get(auditLogUrl);

  check(getAuditRes, {
    "GET Audit Logs status is 200": (r) => r.status === 200,
  });

  // 5. Random sleep
  sleep(Math.random() * 0.5 + 0.1);
}

export function handleSummary(data) {
  return {
    [`./report/k6_report_${__ENV.TYPE}.txt`]:
      textSummary(data, { indent: " ", enableColors: false }),
  };
}