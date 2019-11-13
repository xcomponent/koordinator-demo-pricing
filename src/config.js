const token = process.env.DEMO_TOKEN;
const reportOutputFilePath = process.env.DEMO_REPORT_OUTPUT || "C:/OUTPUT PATH";
const outputReportLink =
  process.env.DEMO_REPORT_LINK ||
  "https://ccenter.xcomponent.com/reports/report.htm";
const taskCatalogUrl =
  process.env.DEMO_TASK_CATALOG_URL || "http://127.0.0.1:8099";
const pollingUrl = process.env.DEMO_POLLING_URL || "http://127.0.0.1:7000";
const taskStatusUrl =
  process.env.DEMO_TASK_STATUS_URL || "http://127.0.0.1:9999";
const singleNode = process.env.DEMO_SINGLE_NODE
  ? process.env.DEMO_SINGLE_NODE === "true"
  : true;

module.exports = {
  token,
  reportOutputFilePath,
  outputReportLink,
  taskCatalogUrl,
  pollingUrl,
  taskStatusUrl,
  singleNode
};
