const uuid = require("uuid/v4");
const helper = require("./helper.js");
const config = require("./config.js");

const koor = require("./koordinator.js");

const namespace = "Demo";
const name = "Report";

const fs = require("fs");

function generateReport(type, name, id_pricing, asOf) {
  fs.readFile("report.htm", "utf8", function(err, data) {
    if (err) {
      return console.log(err);
    }

    var result = data
      .replace(/\$type/g, type)
      .replace(/\$name/g, name)
      .replace(/\$idPricing/g, id_pricing)
      .replace(/\$asOf/g, asOf);

    fs.writeFile(config.reportOutputFilePath, result, "utf8", function(err) {
      if (err) return console.log(err);
    });
  });
}

koor.postCatalog({
  namespace: namespace,
  name: name,
  displayName: name,
  inputs: [
    {
      name: "type",
      baseType: "string"
    },
    {
      name: "name",
      baseType: "string"
    },
    {
      name: "asOf",
      baseType: "string"
    },
    {
      name: "id_pricing",
      baseType: "string"
    }
  ],
  outputs: [
    {
      name: "url",
      baseType: "string"
    }
  ],
  versionNumber: 3,
  schemaVersion: 0
});

koor.pollingLoop(namespace, name, async task => {
  await koor.postStatus(task, {
    status: "InProgress",
    message: `Generating report ${task.inputData.id_pricing}...`
  });

  for (let index = 0; index < 100; index += 5) {
    await koor.postStatus(task, {
      status: "InProgress",
      message: `${index.toFixed(0)}%`
    });

    index += Math.random() * 5;
    helper.shortSleep();
  }

  helper.shortSleep();

  const generatedReport = config.outputReportLink;

  generateReport(
    task.inputData.type,
    task.inputData.type,
    task.inputData.id_pricing,
    task.inputData.asOf
  );

  await koor.postStatus(task, {
    status: "Completed",
    outputValues: {
      url: generatedReport
    },
    message: `DONE [Report](${generatedReport})`
  });
});
