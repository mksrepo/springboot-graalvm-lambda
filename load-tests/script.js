// Load test script for Spring Boot application
import http from "k6/http";
import { check, sleep } from "k6";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";

// Load environment variables
export let options = {
  vus: 10,
  duration: "5m",
};

export default function () {
  // 1. Create a Product (POST)
  const payload = JSON.stringify({
    name: "Load Test Product",
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

  // 2. List Products (GET)
  const getRes = http.get(__ENV.URL);

  check(getRes, {
    "GET status is 200": (r) => r.status === 200,
    "Response has body": (r) => r.body.length > 0,
  });
}

export function handleSummary(data) {
  return {
    [`./report/k6_report_${__ENV.TYPE}.txt`]:
      textSummary(data, { indent: " ", enableColors: false }),
  };
}