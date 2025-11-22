import http from "k6/http";
import { check, sleep } from "k6";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";

export let options = {
  vus: 10,
  duration: "5s",
};

export default function () {
  const res = http.get(__ENV.URL);

  check(res, {
    "status is 200": (r) => r.status === 200,
  });

  sleep(1);
}

export function handleSummary(data) {
  return {
    [`./report/k6_${__ENV.TYPE}.txt`]:
      textSummary(data, { indent: " ", enableColors: false }),
  };
}